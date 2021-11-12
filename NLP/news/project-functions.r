suppressPackageStartupMessages({
    library(data.table)
    library(quanteda)
    library(spacyr)
    library(parallel)
    library(textclean)
    library(fastTextR)
    library(dbscan)
    library(digest)
    library(FNN)
    library(igraph)
})

source('../tree-functions.r')

progressbar <-  function(n, length = 50L) {
    if (length > n) {
        length <- n
    }
    if (length >= 3L) {
        cat(sprintf("|%s|\n", paste(rep("-", length - 2L), collapse = "")))
    }
    else {
        cat(paste(c(rep("|", length), "\n"), collapse = ""))
    }
    s <- seq_len(n)
    sp <- s/n * length
    target <- seq_len(length)
    ids <- sapply(target, function(x) which.min(abs(sp - x)))
    return(ids)
}

## * CORPUS

import.corpus <- function(infile       = opt('corpus.original'),
                          text_var     = opt('text.var'),
                          id_var       = opt('id.var'),
                          group_id_var = opt('group.id.var'),
                          covariates   = opt('covariates'),
                          outfile      = projfile(opt('corpus.imported'))) {

    state <- check.state(infile, text_var, id_var, group_id_var, covariates, outfile = outfile)
    if (state$status == 0) return(invisible(state$output))
    
    cat('Importing corpus...\n')
    if (!file.exists(infile))
        stop('Corpus file not found')
    corpus <- readRDS(infile)

    if (is.null(text_var))
        stop('Argument `text_var` is empty')

    if (is.null(id_var)) {
        corpus[, text_id := sprintf(sprintf('txt_%%0.%ii', nchar(.N)), .I)]
    } else {
        corpus[, text_id := get(id_var)]
    }
    
    if (is.null(group_id_var)) {
        corpus[, text_group_id := text_id]
    } else {
        corpus[, text_group_id := get(group_id_var)]
    }

    corpus[, text := get(text_var)]

    if (!is.null(covariates)) {
        if ('ALL' %in% covariates)  covariates <- names(corpus)
        covariates <- setdiff(covariates, c('text_group_id', 'text_id', 'text',
                                            text_var, id_var, group_id_var))
    }
    
    vars2keep <- c('text_group_id', 'text_id', 'text', covariates)
    d <- corpus[, ..vars2keep]

    saveRDS(corpus[, .N, .(text_group_id, text_id)], replace.file(projfile(opt('text.id.lookup'))))
    saveRDS(d, replace.file(outfile))
    success(state)
    return(invisible(d))
}


preclean.corpus <- function(corpus = NULL, rules = opt('rules'),
                            infile = projfile(opt('corpus.imported')),
                            outfile = projfile(opt('corpus.precleaned'))
                            ) {

    state <- check.state(corpus, rules, infile, outfile = outfile)
    if (state$status == 0) return(invisible(state$output))
    
    cat('Pre-cleaning text...\n')

    if (is.null(corpus)) {
        if (!file.exists(infile))  stop('Corpus not yet imported. Call `import.corpus()` first.')
        corpus <- readRDS(infile)
    }

    if (!is.null(rules)) {
        rules <- as.data.table(matrix(rules, byrow = T, ncol = 2))
        setnames(rules, c('from', 'to'))
        for (i in nrow(rules)) {
            corpus[, text := gsub(rules[i, from], rules[i, to], text)]
        }
    }
    corpus[, text := gsub('</*p>|</*span>|</*em>', ' ', text, perl=T)]
    corpus[, text := gsub('"', '', text, fixed=T)]
    corpus[, text := gsub('[()]', '', text, perl=T)]
    corpus[, text := textclean::replace_contraction(text)]
    saveRDS(corpus, replace.file(outfile))
    success(state)
    return(invisible(corpus))
}


## * SPACY PARSING

consolidate.entity <- function(parsed_corpus=NULL, entities=NULL,
                               infiles = c(parsed_corpus = projfile(opt('parsed.corpus')),
                                          entities = projfile(opt('entities'))),
                               outfile = projfile(opt('parsed.corpus.cons'))) {

    state <- check.state(parsed_corpus, entities, infiles, outfile = outfile)
    if (state$status == 0) return(invisible(state$output))
    
    cat('Consolidating entities...\n')

    if (is.null(parsed_corpus)) {
        if (!file.exists(infiles[['parsed_corpus']]))
            stop('Parsed corpus not yet parsed. Call `parse.corpus()` first.')
        parsed_corpus <- readRDS(infiles[['parsed_corpus']])
    }
    if (is.null(entities)) {
        if (!file.exists(infiles[['entities']]))  stop('Entities file not found. Call `parse.corpus()` first.')
        ents <- readRDS(infiles[['entities']])
    } else ents <- entities
    
    parsed <- entity_consolidate(parsed_corpus)
    setDT(parsed)
    parsed[ents, entities := T, on = c('token' = 'entity', 'doc_id', 'sentence_id')]
    torepl <- ents[entity_type %in% c('CARDINAL', 'DATE', 'PERCENT', 'ORDINAL', 'TIME', 'QUANTITY', 'MONEY') &
                   grepl('_', entity, fixed=T)]
    parsed[torepl, repl := T, on = c('token' = 'entity')]
    parsed[repl == T, token := gsub('_', ' ', token, fixed=T)]
    parsed[, repl := NULL]

    saveRDS(parsed, replace.file(outfile))
    success(state)
    return(invisible(parsed))
}


parse.corpus <- function(corpus               = NULL,
                         consolidate_entities = opt('consolidate.entities', T),
                         ncores               = getOption("mc.cores", 2L),
                         infile               = projfile(opt('corpus.precleaned')),
                         outfile              = projfile(opt('parsed.corpus'))) {

    state <- check.state(corpus, consolidate_entities, infile, outfile = outfile)
    if (state$status == 0) return(invisible(state$output))

    quanteda_options(threads = ncores)

    cat('Parsing text... May take some time!\n')
    
    if (is.null(corpus)) {
        if (!file.exists(infile))  stop('Corpus not yet pre-cleaned. Call `preclean.corpus()` first.')
        corpus <- readRDS(infile)
    }
    
    txt <- corpus$text
    names(txt) <- corpus$text_id

    ## ** Parse with Spacy
    spacy_initialize(model = "en_core_web_md", python_executable = '/usr/bin/python3')

    fun <- function(t) {
        d <- spacy_parse(t, tag=F, lemma=F, dependency = F, nounphrase = F, additional_attributes = c("text"),
                         multithread = T)
        return(d)
    }

    s <- split(txt, rep(seq_len(ncores), length.out = length(txt)))
    system.time({
        p <- mclapply(s, fun, mc.cores = ncores)
    })
    parsed <- do.call('rbind', p)

    ## ** Entities
    ents <- entity_extract(parsed, type = 'all')
    setDT(ents)
    saveRDS(ents, replace.file(projfile(opt('entities'))))

    ## ** Consolidate entities
    if (consolidate_entities) {
        parsed <- consolidate.entity(parsed)
    }

    saveRDS(parsed, replace.file(outfile))

    ## ** Data.table version
    parsedt <- copy(parsed)
    setDT(parsedt)
    setnames(parsedt, 'doc_id', 'text_id')
    saveRDS(parsedt, replace.file(projfile(opt('parsed.corpus.dt'))))

    success(state)
    return(invisible(parsed))
}


reform.corpus <- function(parsed_corpus=NULL, from_consolidated = opt('consolidate.entities', T),
                          infile = ifelse(opt('consolidate.entities'),
                                          projfile(opt('parsed.corpus.cons')),
                                          projfile(opt('parsed.corpus'))),
                          outfile = projfile(opt('reformed.corpus'))) {

## parsed_corpus=NULL;  from_consolidated = opt('consolidate.entities', T); infile = ifelse(opt('consolidate.entities'), projfile(opt('parsed.corpus.cons')), projfile(opt('parsed.corpus'))); outfile = projfile(opt('reformed.corpus'))

    state <- check.state(parsed_corpus, from_consolidated, infile, outfile = outfile)
    if (state$status == 0) return(invisible(state$output))

    cat(sprintf('Re-forming corpus from %sconsolidated parsed corpus...\n',
                fifelse(from_consolidated, '', 'non-')))

    if (is.null(parsed_corpus)) {
        if (!file.exists(infile))  stop('Parsed corpus not available. Call `parse.corpus()` or `consolidate.entity()` first.')
        parsed_corpus <- readRDS(infile)
    }

    parsed_corpus[grep('^[0-9,]{5,}$', token, perl=T), token := gsub(',', '', token, fixed=T)]
    parsed_corpus[grep(' %', token, perl=T), token := gsub(' +%', '%', token, perl=T)]
    parsed_corpus[
      , token_clean := trimws(gsub(' {2,}', ' ',
                                   fifelse(entities %in% T &
                                           !(entities %in% c('MONEY', 'CARDINAL', 'DATE', 'PERCENT',
                                                             'ORDINAL', 'TIME', 'QUANTITY')), token,
                                    tolower(gsub('[^a-zA-Z0-9_ āēīōūĀĒĪŌŪ%$]', ' ', token, perl=T))), perl=T))]

    corp <- parsed_corpus[!grepl('^ *$', token_clean, perl=T)
                        , .(text=paste0(token_clean, collapse=' '))
                        , .(text_id=doc_id)]
    
    saveRDS(corp, replace.file(outfile))
    success(state)
    return(invisible(corp))
    
}


## * UNSUPERVISED TRAINING
unsupervised.training <- function(corpus       = NULL,
                                  modeltype    = opt('modeltype'),
                                  bucket       = opt('bucket'),
                                  dim          = opt('dim'),
                                  epoch        = opt('epoch'),
                                  label        = opt('label'),
                                  loss         = opt('loss'),
                                  lr           = opt('lr'),
                                  lrUpdate     = opt('lrUpdate'),
                                  maxn         = opt('maxn'),
                                  minCount     = opt('minCount'),
                                  minn         = opt('minn'),
                                  neg          = opt('neg'),
                                  t            = opt('t'),
                                  verbose      = opt('verbose'),
                                  wordNgrams   = opt('wordNgrams'),
                                  ws           = opt('ws'),
                                  pretrained.vec = opt('pretrained.vec'),
                                  ncores       = getOption("mc.cores", 2L),
                                  infile       = projfile(opt('reformed.corpus')),
                                  outfile      = projfile(opt('model.file'))) {

## corpus = NULL; modeltype = opt('modeltype'); bucket = opt('bucket'); dim = opt('dim'); epoch = opt('epoch'); label = opt('label'); loss = opt('loss'); lr = opt('lr'); lrUpdate = opt('lrUpdate'); maxn = opt('maxn'); minCount = opt('minCount'); minn = opt('minn'); neg = opt('neg'); t = opt('t'); verbose = opt('verbose'); wordNgrams = opt('wordNgrams'); ws = opt('ws'); ncores = getOption("mc.cores", 2L); infile = projfile(opt('reformed.corpus')); outfile = projfile(opt('model.file'))
    
    state <- check.state(corpus, modeltype, bucket, dim, epoch, label, loss, lr, lrUpdate, maxn,
                         minCount, minn, neg, t, verbose, wordNgrams, ws, infile,
                         outfile = outfile, readfun = NULL, pretrained.vec)
    if (state$status == 0) return(invisible(state$output))
        
    cat('Fitting unsupervised model...\n')

    if (is.null(corpus)) {
        if (!file.exists(infile))  stop('Corpus not yet cleaned. Call `clean_corpus()` first.')
        corpus <- readRDS(infile)
    }

    tmpfile <- tempfile(tmpdir='.', fileext = '.txt')
    fwrite(corpus, tmpfile, col.names = F)

    cntrl <- ft_control(
        loss          = loss,
        learning_rate = lr,
        learn_update  = lrUpdate,
        word_vec_size = dim,
        window_size   = ws,
        epoch         = epoch,
        min_count     = minCount,
        neg           = neg,
        min_ngram     = minn,
        max_ngram     = maxn,
        max_len_ngram = wordNgrams,
        nbuckets      = bucket,
        threshold     = t,
        label         = label,
        verbose       = verbose,
        output        = outfile,
        save_output   = T,
        nthreads      = ncores,
        pretrained_vectors = pretrained.vec
        )

    model <- ft_train(tmpfile, method = modeltype, control = cntrl)
    ft_save(model, outfile)
    
    success(state)
    return(invisible(outfile))
}


tfidf <- function(corpus=NULL, model=NULL,
                  infiles = c(corpus = projfile(opt('reformed.corpus')),
                              modelfile = projfile(opt('model.file'))),
                  outfile = projfile(opt('text.tfidf'))) {

    state <- check.state(corpus, model, infiles, outfile = outfile)
    if (state$status == 0) return(invisible(state$output))

    cat('Calculating TF-IDF...\n')

    if (is.null(corpus)) {
        if (!file.exists(infiles[['corpus']]))
            stop('Corpus not yet cleaned. Call `clean_corpus()` first')
        corpus <- readRDS(infiles[['corpus']])
    }
    if (is.null(model)) {
        if (!file.exists(infiles[['modelfile']]))
            stop('Unsupervised model not yet trained. Call `unsupervised.training()` first.')
        model <- ft_load(infiles[['modelfile']])
    } else model <- load_model(model)
    
    toks <- tokenize_fastestword(corpus$text)
    
    names(toks) <- corpus$text_id
    tdt <- utils::stack(toks)
    setDT(tdt)
    tdt[, ind := as.integer(ind)]
    setnames(tdt, c('word', 'text_id'))
    lkup <- readRDS(projfile(opt('text.id.lookup')))
    tdt[lkup, text_group_id := i.text_group_id, on = 'text_id']

    tfs <- tdt[, .(indoc = .N), .(word, text_group_id)]
    tfs[, tot_occ := sum(indoc), word]
    tfs[, totdoc := sum(indoc), text_group_id]
    tfs[, tf := indoc / totdoc]

    tot.docs <- tdt[, uniqueN(text_group_id)]
    idfs <- tdt[, .(ndocs = uniqueN(text_group_id)), word]
    idfs[, totdocs := tot.docs]
    idfs[, idf := log(totdocs / ndocs)]
    tfs[idfs, idf := i.idf, on = 'word']
    tfs[, tf_idf := tf * idf]

    saveRDS(tfs, replace.file(outfile))
    success(state)
    return(invisible(tfs))
}


aggregate.embeddings <- function(corpus=NULL, model=NULL,
                                 method = opt('aggregate.method'), tfidf=NULL,
                                 infiles = c(corpus = projfile(opt('reformed.corpus')),
                                             model  = projfile(opt('model.file')),
                                             idlkup = projfile(opt('text.id.lookup'))),
                                 outfile = projfile(opt('embeddings'))) {
## corpus=NULL; model=NULL; method = opt('aggregate.method'); tfidf=NULL; infiles = c(corpus = projfile(opt('reformed.corpus')), model  = projfile(opt('model.file')), idlkup = projfile(opt('text.id.lookup'))); outfile = projfile(opt('embeddings'))

    state <- check.state(corpus, model, method, tfidf, infiles, outfile = outfile)
    if (state$status == 0) return(invisible(state$output))
    
    if (!(method %in% c('basic', 'tf-idf', 'idf')))
        stop('Aggregating method should be one of `basic`, `tf-idf`, `idf`')
    
    cat(sprintf('Aggregating embeddings (%s method)...\n', method))

    if (is.null(corpus)) {
        if (!file.exists(infiles[['corpus']]))
            stop('Corpus not yet cleaned. Call `clean_corpus()` first')
        corpus <- readRDS(infiles[['corpus']])
    }
    if (is.null(model)) {
        if (!file.exists(infiles[['model']]))
            stop('Unsupervised model not yet trained. Call `unsupervised.training()` first.')
        model <- ft_load(infiles[['model']])
    } else model <- ft_load(model)
    
    if (method == 'basic') {

        l <- lapply(corpus$text, function(x) {
            v <- ft_word_vectors(model, unlist(tokenize_fastestword(x)))
            colMeans(v)
        })
        m <- do.call(rbind, l)
        rownames(m) <- corpus$text_id

        txtvec <- m
        
    } else if (method == 'tf-idf') {

        ## ** Get tf-idf
        if (is.null(tfidf)) {
            if (!file.exists(projfile(opt('text.tfidf')))) {
                tfidf <- tfidf(corpus, model)
            } else tfidf <- readRDS(projfile(opt('text.tfidf')))
        }

        ## ** Weighted average of word vectors based on tf-idf
        i=1
        txtvec <- do.call('rbind', mclapply(seq_along(corpus$text), function(i) {
            vec <- get_word_vectors(model, toks[[i]])
            normvec <- apply(vec, 1, function(x) sqrt(sum(x^2)))
            normvec <- fifelse(normvec > 0, normvec, 1)
            y <- vec / normvec
            tfs1 <- tfidf[text_group_id == corpus$text_group_id[i]]
            wt <- tfs1[match(rownames(y), word), tf_idf]
            return(colSums(y * wt) / sum(wt))
        }, mc.cores = 6))

        rownames(txtvec) <- corpus$text_id
        
    } else if (method == 'idf') {

        ## ** Calculate idf
        tdt <- corpus[, .(word = unlist(tokenize_fastestword(text))),
                      .(text_id = as.integer(as.character(text_id)))]
        lkup <- readRDS(infiles[['idlkup']])
        tdt[lkup, text_group_id := i.text_group_id, on = 'text_id']

        tot.docs <- tdt[, uniqueN(text_group_id)]
        idfs <- tdt[, .(ndocs = uniqueN(text_group_id)), word]
        idfs[, totdocs := tot.docs]
        idfs[, idf := log(totdocs / ndocs)]

        wv <- ft_word_vectors(model, ft_words(model))

        wvdt <- as.data.table(wv, keep.rownames = T)
        wvdt <- melt(wvdt, id.vars = 'rn')
        wvdt[, variable := as.integer(variable)]
        wvdt[, normv := sqrt(sum(value^2)), rn]
        
        wvdt[, y := value / normv]

        tdt[idfs, idf := i.idf, on = 'word']

        tdt1 <- tdt
        wvdt1 <- wvdt[rn %in% unique(tdt1$word)]

        tdt1[, chunk := text_id %% 24]

        txtvec3 <- do.call(rbind, mclapply(tdt1[, unique(chunk)], function(ch) {
            w <- wvdt1[tdt1[chunk == ch], on = c('rn' = 'word'), allow.cartesian=T, nomatch=0]
            w[, .(value = sum(y * idf) / sum(idf)), .(variable, text_id)]
        }, mc.cores = 3))

        txtvec <- dcast(txtvec3, text_id ~ variable)
        txtvec <- as.matrix(txtvec, rownames=1)
        
    } else stop('Method not recognised')
    
    saveRDS(txtvec, replace.file(outfile))
    success(state)
    return(invisible(txtvec))
}

aggregate.embeddings.docs <- function(embeddings=NULL, idlkup=NULL,
                                 infiles = c(embeddings = projfile(opt('embeddings')),
                                             idlkup = projfile(opt('text.id.lookup'))),
                                 outfile = projfile(opt('embeddings.docs'))) {
## embeddings=NULL; infiles = c(embeddings = projfile(opt('embeddings')), idlkup = projfile(opt('text.id.lookup'))); outfile = projfile(opt('embeddings.docs'))
    state <- check.state(embeddings, infiles, outfile = outfile)
    if (state$status == 0) return(invisible(state$output))
    
    cat('Aggregating embeddings by document...\n')

    if (is.null(embeddings)) {
        if (!file.exists(infiles[['embeddings']]))
            stop('Embeddings not yet calculated. Call `aggregate.embeddings()` first')
        embs <- readRDS(infiles[['embeddings']])
    }

    if (is.null(idlkup)) {
        idlkup <- readRDS(infiles[['idlkup']])
    }

    idlkup <- idlkup[match(as.integer(rownames(embs)), text_id)]
    stopifnot(identical(idlkup$text_id, as.integer(rownames(embs))))

    e <- as.data.table(embs, keep.rownames=T)
    e <- melt(e, id.vars = 'rn')
    e[, rn := as.integer(rn)]
    e[idlkup, text_group_id := i.text_group_id, on = c('rn' = 'text_id')]
    e <- e[, mean(value), .(text_group_id, variable)]
    e <- dcast(e, text_group_id ~ variable, value.var = 'V1')
    e <- as.matrix(e, rownames = 'text_group_id')

    saveRDS(e, replace.file(outfile))

}

calc.distances <- function(embeddings = NULL, corpus=NULL, 
                           infiles = c(embs = projfile(opt('embeddings')),
                                       corp = projfile(opt('corpus.imported'))),
                           outfile = projfile(opt('doc.distances'))) {
## embeddings = NULL; corpus=NULL; infiles = c(embs = projfile(opt('embeddings')), corp = projfile(opt('corpus.imported'))); outfile = projfile(opt('tree.data'))
    state <- check.state(embeddings, corpus, infiles, outfile = outfile)
    if (state$status == 0) return(invisible(state$output))

    if (is.null(embeddings)) {
        if (!file.exists(infiles[['embs']]))
            stop('Embeddings not yet aggregated. Call `aggregate.embeddings()` first')
        embs <- readRDS(infiles[['embs']])
    } else embs <- embeddings

    if (is.null(corpus)) {
        if (!file.exists(infiles[['corp']]))
            stop('Corpus not yet created.')
        corpus <- readRDS(infiles[['corp']])
    }
    
    Matrix <- as.matrix(embs)
    sim <- Matrix / sqrt(rowSums(Matrix * Matrix))
    sim <- sim %*% t(sim)
    D_sim <- as.dist(1 - sim)
    dm <- D_sim

    saveRDS(dm, replace.file(outfile))
    success(state)
    return(invisible(dm))

}

most.similar <- function(distances = NULL, corpus = NULL, n.simils = 5L,
                         infiles = c(distances = projfile(opt('doc.distances')),
                                     corp = projfile(opt('corpus.imported'))),
                         outfile = projfile(opt('doc.simils'))) {
    state <- check.state(distances, n.simils, infiles, outfile = outfile)
    if (state$status == 0) return(invisible(state$output))

    if (is.null(distances)) {
        if (!file.exists(infiles[['distances']]))
            stop('Distances not yet calculated. Call `calc.distances()` first')
        dists <- readRDS(infiles[['distances']])
    } else dists <- distances
    dists <- as.matrix(dists)

    if (is.null(corpus)) {
        if (!file.exists(infiles[['corp']]))
            stop('Corpus not yet created.')
        corpus <- readRDS(infiles[['corp']])
    }

    rownames(dists) <- corpus[match(as.integer(rownames(dists)), text_id),
                              sub('\\.md$', '', text_group_id)]
    colnames(dists) <- corpus[match(as.integer(colnames(dists)), text_id),
                              sub('\\.md$', '', text_group_id)]

    most.simils <- sapply(rownames(dists), function(x) {
        names(head(sort(dists[x,]), n.simils+1L)[-1])
    }, simplify=F)

    jsonlite::write_json(most.simils, replace.file(basename(outfile)))
    out <- jsonlite::write_json(most.simils, replace.file(outfile))

    success(state)
    return(invisible(out))

}

deck2d <- function(d, xvar, yvar, labvar=NULL, colvar=NULL, zoom = 3, width = 1400, height = 800,
                   opacity = 0.5) {

    library(deckgl)
    
    if (!is.data.table(d)) {
        d <- as.data.table(d)
    }
    if (is.null(colvar)) {
        d[, col := "#5B3456"]
    } else d[, col := get(colvar)]
    properties <- list(
        getPosition = get_position(xvar, yvar),
        getColor = get_color_to_rgb_array('col'),
        getFillColor = get_color_to_rgb_array('col')
    )
    if (!is.null(labvar)) {
        d[, lab := get(labvar)]
        properties$getTooltip = JS("object =>`${object.lab}`")
    }
    xm <- d[, median(get(xvar), na.rm=T)]
    ym <- d[, median(get(yvar), na.rm=T)]

    deck <- deckgl(latitude = ym, longitude = xm, zoom = zoom, width=width, height=height,
                   style = list(background = "#F5F5F5")) %>%
        add_scatterplot_layer(data = d,
                              properties = properties,
                              getRadius = 500,
                              radiusScale = 18,
                              radiusMinPixels = 3,
                              radiusMaxPixels = 10,
                              opacity = opacity
                              )
    deck

}


umap.plot <- function(distances = NULL, corpus = NULL, 
                      infiles = c(distances = projfile(opt('doc.distances')),
                                  corp = projfile(opt('corpus.imported'))),
                      outfile = projfile(opt('umap.plot'))) {

    state <- check.state(distances, corpus, infiles, outfile = outfile)
    if (state$status == 0) return(invisible(state$output))

    if (is.null(distances)) {
        if (!file.exists(infiles[['distances']]))
            stop('Distances not yet calculated. Call `calc.distances()` first')
        dists <- readRDS(infiles[['distances']])
    } else dists <- distances
    dists <- as.matrix(dists)

    if (is.null(corpus)) {
        if (!file.exists(infiles[['corp']]))
            stop('Corpus not yet created.')
        corpus <- readRDS(infiles[['corp']])
    }
    corpus[, text_group_id := gsub('\\.md$', '', text_group_id)]

    labs <- corpus[match(as.numeric(rownames(dists)), text_id),
                   sprintf('<b>%s</b><br><i>%s</i><br>%s',
                           text_group_id, title, text)]
    
    u <- uwot::tumap(dists)
    d <- as.data.table(u)

    d[, lab := labs]
    
    deck <- deck2d(d, 'V1', 'V2', 'lab', zoom = 5)

    htmlwidgets::saveWidget(deck, replace.file(outfile))

    success(state)
    return(invisible(deck))
}


make.tree <- function(distances = NULL, corpus = NULL, square.edges = opt('square.edges'),
                      infiles = c(distances = projfile(opt('doc.distances')),
                                  corp = projfile(opt('corpus.imported'))),
                      outfile = projfile(opt('tree'))) {

    state <- check.state(distances, corpus, square.edges, infiles, outfile = outfile)
    if (state$status == 0) return(invisible(state$output))

    if (is.null(distances)) {
        if (!file.exists(infiles[['distances']]))
            stop('Distances not yet calculated. Call `calc.distances()` first')
        dists0 <- readRDS(infiles[['distances']])
    } else dists0 <- distances
    dists <- as.matrix(dists0)

    if (is.null(corpus)) {
        if (!file.exists(infiles[['corp']]))
            stop('Corpus not yet created.')
        corpus <- readRDS(infiles[['corp']])
    }
    corpus[, text_group_id := gsub('\\.md$', '', text_group_id)]
    
    library(ape)
    ## library(phangorn)

    labs <- corpus[match(as.numeric(rownames(dists)), text_id),
                   sprintf('<b>%s</b><br><i>%s</i><br>%s',
                           text_group_id, title, text)]

    tree <- bionj(dists)
    
    tree$tip.label <- corpus[match(as.numeric(tree$tip.label), text_id), sub('\\.md$', '', text_group_id)]

    edges <- as.data.table(tree$edge)
    setnames(edges, c('from', 'to'))
    edges[, eid := .I]

    tips <- data.table(label = tree$tip.label)[, id := .I]
    edges[, to.tip := to %in% tips$id]

    ## ** Get coordinates without plotting
    p <- plot2(tree, type = 'phylogram', plot = F,
               show.tip.label = F, show.node.label = F,
               edge.color = 'black', tip.color = 'red', cex = 0,
               root.edge = F, use.edge.length = T,
               no.margin = T, direction = 'rightwards')

    ed <- data.table(p$coords$edge)
    xy <- data.table(x = p$coords$xx, y = p$coords$yy)
    xy[, id := .I]

    edges[xy, `:=`(from.x = i.x, from.y = i.y), on = c('from' = 'id')]
    edges[xy, `:=`(to.x = i.x, to.y = i.y), on = c('to' = 'id')]

    ## ** Make square segments
    if (square.edges) {
        e <- edges[from.x != to.x & from.y != to.y]
        ed <- e[, .(to.x = c(from.x, to.x), from.y = c(from.y, to.y), to.tip = c(F, first(to.tip)),
                    extra = c(T, F))
              , .(from, to, eid)]
        
        ed <- merge(ed, e[, c('eid', setdiff(names(e), names(ed))), with=F], by = 'eid')
        ed <- rbind(ed, edges[!(from.x != to.x & from.y != to.y)], fill = T)
    } else ed <- copy(edges)

    te <- copy(ed)

    te[, seq_id := rowid(eid)]

    ## ** Deck tree
    te[, col := '#43A1C9']

    te[tips, text_group_id := i.label, on = c('to' = 'id')]
    te[corpus, `:=`(title = i.title, text = i.text), on = 'text_group_id']
    setnames(te, c('title', 'text'), c('pubtitle', 'pubtext'))

    deck <- tree2deck(tedges=te, edges.colour.by = 'col', points.colour.by = 'col', tooltip = T,
                      edge.vars = c('eid'),
                      edge.lab.glue = '',
                      point.vars = c('eid', 'pubtitle', 'text_group_id', 'pubtitle', 'pubtext'),
                      node.lab.glue = '{eid}: <b>{text_group_id}</b><br><i>{pubtitle}</i><br>{pubtext}')

    htmlwidgets::saveWidget(deck, replace.file(outfile))

    success(state)
    return(invisible(deck))

}


make.tree2 <- function(distances = NULL, corpus = NULL, 
                       infiles = c(distances = projfile(opt('doc.distances')),
                                   corp = projfile(opt('corpus.imported'))),
                       outfile = projfile(opt('tree2'))) {

    state <- check.state(distances, corpus, infiles, outfile = outfile)
    if (state$status == 0) return(invisible(state$output))

    if (is.null(distances)) {
        if (!file.exists(infiles[['distances']]))
            stop('Distances not yet calculated. Call `calc.distances()` first')
        dists <- readRDS(infiles[['distances']])
    } else dists <- distances
    dists <- as.matrix(dists)

    if (is.null(corpus)) {
        if (!file.exists(infiles[['corp']]))
            stop('Corpus not yet created.')
        corpus <- readRDS(infiles[['corp']])
    }
    corpus[, text_group_id := gsub('\\.md$', '', text_group_id)]

    library(visNetwork)

    rownames(dists) <- corpus[match(as.numeric(rownames(dists)), text_id), sub('\\.md$', '', text_group_id)]
    colnames(dists) <- corpus[match(as.numeric(colnames(dists)), text_id), sub('\\.md$', '', text_group_id)]

    g <- graph.adjacency(dists, mode = 'directed', weighted=T, diag=F)
    ## g <- simplify(g, remove.multiple=TRUE, remove.loops=TRUE)
    ## E(g)$weight <- abs(E(g)$weight)
    ## g <- delete_edges(g, E(g)[which(E(g)$weight<0.8)])
    ## g <- delete.vertices(g, degree(g)==0)
    mst <- igraph::mst(g, algorithm="prim")
    ## visIgraph(mst)

    visnet <- toVisNetworkData(mst)
    visnet$nodes$title <- corpus[match(visnet$nodes$id, sub('\\.md$', '', text_group_id)),
                                 sprintf('<b>%s</b><br><i>%s</i><br>%s', text_group_id, title, text)]

    
    vis <- visNetwork(nodes=visnet$nodes, edges=visnet$edges, width='1600px', heigh='1000px') %>%
        ## visIgraphLayout(layout = 'layout_in_circle') %>%
        ## visLayout(hierarchical = T) %>%
        visHierarchicalLayout() %>%
        visEdges(width = 5, color = "#9DC4A9") %>%
        visNodes(size = 20, color = "#50AD8577") %>%
        ## visHierarchicalLayout() %>%
        ## visClusteringByHubsize(size = 3) %>%
        visOptions(highlightNearest = F, #list(hover=T),
                   collapse = F, clickToUse = F)  %>%
        visPhysics(stabilization = F, #maxVelocity = 5000, minVelocity = 0.01, timestep=0.8,
                   ## repulsion = list(nodeDistance = 2000),
                   ## solver = 'hierarchicalRepulsion',
                   hierarchicalRepulsion = list(nodeDistance = 20
                                              ## , centralGravity = -0.01
                                              , springLength = 1
                                              , springConstant = 0.00001
                                                ))
    
    htmlwidgets::saveWidget(vis, replace.file(outfile))

    success(state)
    return(invisible(vis))
}


do.umap <- function(embeddings = NULL, dims = opt('dims', 2L), pkg = opt('umap.pkg','uwot'),
                    normalise = opt('normalise',F),
                    infiles = projfile(opt('embeddings')),
                    outfile = projfile(opt('embeddings.umap'))) {
## embeddings = NULL; dims = opt('dims', 2L); pkg = opt('umap.pkg','uwot'); normalise = opt('normalise',F); infiles = projfile(opt('embeddings')); outfile = projfile(opt('embeddings.umap')); run_suff=NULL

## embeddings = NULL; dims = 2L; pkg = opt('umap.pkg','uwot'); normalise = opt('normalise',F); infiles = projfile(opt('embeddings')); outfile = projfile(opt('embeddings.umap')); run_suff=NULL
    
    state <- check.state(dims, pkg, normalise, infiles, outfile = outfile)
    if (state$status == 0) return(invisible(state$output))
    
    cat(sprintf('UMAP fitting to %i dimensions...\n', dims))

    if (is.null(embeddings)) {
        if (!file.exists(infiles))
            stop('Embeddings not yet aggregated. Call `aggregate.embeddings()` first')
        embs <- readRDS(infiles)
    } else embs <- embeddings

    if (normalise) {
        normvec <- apply(embs, 1, function(x) sqrt(sum(x^2)))
        normvec <- fifelse(normvec > 0, normvec, 1)
        embs <- embs / normvec
    }

    if (pkg == 'umap') {
        library(umap)
        custom.config <- umap.defaults
        custom.config$n_components <- dims
        custom.config$n_neighbors <- opt('umap.n.neighbours')
        custom.config$n_epochs <- opt('umap.n.epochs')
        custom.config$spread <- opt('umap.spread')
        um <- umap::umap(embs, custom.config, method = 'umap-learn')
        dt <- as.data.frame(um$layout)
    } else if (pkg == 'uwot') {
        print(system.time({
            um <- uwot::umap(embs, n_components = dims,
                             n_neighbors = opt('umap.n.neighbours'),
                             n_epochs = opt('umap.n.epochs'),
                             n_threads = getOption('mc.cores'),
                             n_sgd_threads = 'auto')
        }))
        dt <- as.data.frame(um)
    } else stop('Only `umap` and `uwot` packages are supported')
    
    setDT(dt)
    setnames(dt, paste0('umap_v', seq_len(ncol(dt))))
    dt[, text_id := rownames(embs)]
    
    saveRDS(dt, replace.file(outfile))
    success(state)
    return(invisible(dt))
}


do.umap.2d <- function(embeddings = NULL, dims = opt('dims', 2L), pkg = opt('umap.pkg','uwot'),
                    normalise = opt('normalise',F),
                    infiles = projfile(opt('embeddings.umap')),
                    outfile = projfile(opt('embeddings.umap.2d'))) {
## embeddings = NULL; dims = opt('dims', 2L); pkg = opt('umap.pkg','uwot'); normalise = opt('normalise',F); infiles = projfile(opt('embeddings')); outfile = projfile(opt('embeddings.umap')); run_suff=NULL

## embeddings = NULL; dims = 2L; pkg = opt('umap.pkg','uwot'); normalise = opt('normalise',F); infiles = projfile(opt('embeddings.umap')); outfile = projfile(opt('embeddings.umap.2d')); run_suff=NULL
    
    state <- check.state(dims, pkg, normalise, infiles, outfile = outfile)
    if (state$status == 0) return(invisible(state$output))
    
    cat(sprintf('UMAP fitting to %i dimensions...\n', dims))

    if (is.null(embeddings)) {
        if (!file.exists(infiles))
            stop('Embeddings not yet aggregated. Call `aggregate.embeddings()` first')
        embs <- readRDS(infiles)
        embs <- as.matrix(embs, rownames = 'text_id')
    } else embs <- embeddings

    if (normalise) {
        normvec <- apply(embs, 1, function(x) sqrt(sum(x^2)))
        normvec <- fifelse(normvec > 0, normvec, 1)
        embs <- embs / normvec
    }

    if (pkg == 'umap') {
        library(umap)
        custom.config <- umap.defaults
        custom.config$n_components <- dims
        custom.config$n_neighbors <- opt('umap.n.neighbours')
        custom.config$n_epochs <- opt('umap.n.epochs')
        custom.config$spread <- opt('umap.spread')
        um <- umap::umap(embs, custom.config, method = 'umap-learn')
        dt <- as.data.frame(um$layout)
    } else if (pkg == 'uwot') {
        ## system.time({
        ##     um <- uwot::umap(embs, n_components = dims,
        ##                      n_neighbors = opt('umap.n.neighbours'),
        ##                      n_epochs = opt('umap.n.epochs'),
        ##                      n_threads = getOption('mc.cores'))
        ## })
        print(system.time({
            um <- uwot::umap(embs, n_components = dims,
                             n_neighbors = opt('umap.n.neighbours'),
                             n_epochs = opt('umap.n.epochs'),
                             n_threads = getOption('mc.cores'),
                             n_sgd_threads = 'auto')
        }))
        dt <- as.data.frame(um)
    } else stop('Only `umap` and `uwot` packages are supported')
    
    setDT(dt)
    setnames(dt, paste0('umap_v', seq_len(ncol(dt))))
    dt[, text_id := rownames(embs)]
    
    saveRDS(dt, replace.file(outfile))
    success(state)
    return(invisible(dt))
}

do.umap.2d.doc <- function(embeddings = NULL, dims = opt('dims', 2L), pkg = opt('umap.pkg','uwot'),
                           n_neighbors = opt('umap.n.neighbours'),
                           n_epochs = opt('umap.n.epochs'),
                           normalise = opt('normalise',F),
                           infiles = projfile(opt('embeddings.docs')),
                           outfile = projfile(opt('embeddings.docs.umap.2d'))) {
    ## embeddings = NULL; dims = opt('dims', 2L); pkg = opt('umap.pkg','uwot'); normalise = opt('normalise',F); infiles = projfile(opt('embeddings.docs')); outfile = projfile(opt('embeddings.docs.umap.2d'))

    state <- check.state(dims, pkg, n_neighbors, n_epochs, normalise, infiles, outfile = outfile)
    if (state$status == 0) return(invisible(state$output))
    
    cat(sprintf('UMAP fitting to %i dimensions by document...\n', dims))

    if (is.null(embeddings)) {
        if (!file.exists(infiles))
            stop('Embeddings not yet aggregated. Call `aggregate.embeddings()` first')
        embs <- readRDS(infiles)
    } else embs <- embeddings

    if (normalise) {
        normvec <- apply(embs, 1, function(x) sqrt(sum(x^2)))
        normvec <- fifelse(normvec > 0, normvec, 1)
        embs <- embs / normvec
    }

    if (pkg == 'umap') {
        library(umap)
        custom.config <- umap.defaults
        custom.config$n_components <- dims
        custom.config$n_neighbors <- n_neighbors
        custom.config$n_epochs <- n_epochs
        custom.config$spread <- opt('umap.spread')
        um <- umap::umap(embs, custom.config, method = 'umap-learn')
        dt <- as.data.frame(um$layout)
    } else if (pkg == 'uwot') {
        print(system.time({
            um <- uwot::umap(embs, n_components = dims,
                             n_neighbors = n_neighbors,
                             n_epochs = n_epochs,
                             n_threads = getOption('mc.cores'),
                             n_sgd_threads = 'auto')
        }))
        dt <- as.data.frame(um)
    } else stop('Only `umap` and `uwot` packages are supported')
    
    setDT(dt)
    setnames(dt, paste0('umap_v', seq_len(ncol(dt))))
    dt[, text_group_id := rownames(embs)]
    
    saveRDS(dt, replace.file(outfile))
    success(state)
    return(invisible(dt))
}

clustering <- function(umapdt = NULL, eps = opt('eps'),
                       infile = projfile(opt('embeddings.umap')),
                       outfile = projfile(opt('text.clusters'))) {

    state <- check.state(umapdt, eps, infile, outfile = outfile)
    if (state$status == 0) return(invisible(state$output))
    
    cat('Clustering of embeddings...\n')

    if (is.null(umapdt)) {
        if (!file.exists(infile))
            stop('UMAP not yet performed. Call `do.umap()` first')
        umapdt <- readRDS(infile)
    }

    dt <- umapdt
    dt_matrix <- as.matrix(dt[, -'text_id'])

    k <- pmax(round(0.001 * nrow(dt)), 3) # max number of neighbours

    cat('\tCalculating KNN distances...\n')
    knn.norm <- get.knn(dt_matrix, k = k)
    knn.norm <- data.frame(from = rep(1:nrow(knn.norm$nn.index), k),
                           to = as.vector(knn.norm$nn.index), weight = 1/(1 + as.vector(knn.norm$nn.dist)))
    cat('\tCalculating graph from data...\n')
    nw.norm <- graph_from_data_frame(knn.norm, directed = FALSE)
    cat('\tSimplifying graph...\n')
    nw.norm <- simplify(nw.norm)
    cat('\tFinding clusters...\n')
    lc.norm <- cluster_louvain(nw.norm)
    dt[, cluster := as.integer(membership(lc.norm))]
    
    resdt <- dt[, .(text_id, cluster)]

    cat('\tPoing density...\n')
    if (is.null(eps))
        eps <- 0.3
    resdt[, dens := pointdensity(dt_matrix, eps, type = 'frequency')]

    cat(resdt[, sprintf('%i clusters found. %0.1f%% of text elements not in clusters\n',
                uniqueN(cluster), 100 * mean(cluster == 0))])

    saveRDS(resdt, replace.file(outfile))
    success(state)
    return(invisible(resdt))
}


label.clusters <- function(textclusters=NULL, corpus=NULL, umap2d=NULL,
                           add.coords = opt('create.map'), max.ngram = opt('max.ngram'),
                           n.tokens = opt('lab.n.tokens'), n.tokens.max = opt('lab.n.tokens.max'),
                           sep = opt('lab.sep'),
                           infiles = c(txt_cl = projfile(opt('text.clusters')),
                                       corp   = projfile(opt('reformed.corpus')),
                                       um2d   = projfile(opt('embeddings.umap.2d'))),
                           outfile = projfile(opt('clusters'))) {

    state <- check.state(textclusters, corpus, umap2d, add.coords, max.ngram, n.tokens, n.tokens.max, sep,
                         infiles, outfile = outfile)
    if (state$status == 0) return(invisible(state$output))
    
    cat('Clusters labelling...\n')

    if (is.null(textclusters)) {
        if (!file.exists(infiles[['txt_cl']]))
            stop('Clustering not yet performed. Call `clustering()` first')
        textclusters <- readRDS(infiles[['txt_cl']])
    }
    if (is.null(corpus)) {
        if (!file.exists(infiles[['corp']]))
            stop('Corpus not yet created.')
        corpus <- readRDS(infiles[['corp']])
    }

    corp <- quanteda::corpus(corpus, docid_field = 'text_id', text_field = 'text')

    ## ** Get tokens
    toksn <- tokens(corp) %>%
        tokens_remove('^[0-9]+$', valuetype = 'regex', verbose=T) %>%
        tokens_select(min_nchar = 3) %>%
        tokens_remove(c(stopwords('english'), letters))
    
    ## tokens_compound(phrase(c("new zealand", "united kingdom", "abortion law", "crime act", "crimes act",
    ##                          "law commission", "zea lander", "human life", "current law",
    ##                          "law change", "proposed law", "abortion service", 
    ##                          "right life", "pregnant woman", "woman abortion",
    ##                          "zea land", "new zea land", "new zea lander", "new zea lander s",
    ##                          "de criminalise", "mental health", "unborn child", "et al",
    ##                          "legal issue", "health issue", "health care", "health system",
    ##                          "moral issue", "woman s", "woman 's", "p re",
    ##                          "mother's", "mother 's", "late term", "don t",
    ##                          "safe area", "safe areas"))) %>%
    ## tokens_compound('[0-9]+[ -]weeks?', valuetype = 'regex') %>%
    ## tokens_compound('[0-9]+[- ]months?', valuetype = 'regex')

    ## ** Remove sequentially duplicated words
    tl <- as.list(toksn)
    tl <- rapply(tl, function(x) x[!(shift(x, fill='') == x)], how = 'replace')
    toksn <- as.tokens(tl)

    ## ** N-grams
    toks12 <- tokens_ngrams(toksn, seq_len(max.ngram))

    tl <- as.list(toks12)
    tdt <- utils::stack(tl)
    setDT(tdt)
    setnames(tdt, c('word', 'text_id'))
    tdt[textclusters, cluster := i.cluster, on = 'text_id']

    ## ** Tf-Idf
    tfs <- tdt[, .(indoc = .N), .(word, cluster)]
    tfs[, tot_occ := sum(indoc), word]
    tfs[, totdoc := sum(indoc), cluster]
    tfs[, tf := indoc / totdoc]

    tot.docs <- tdt[, uniqueN(cluster)]
    idfs <- tdt[, .(ndocs = uniqueN(cluster)), word]
    idfs[, totdocs := tot.docs]
    idfs[, idf     := log(totdocs / ndocs)]
    tfs[idfs, idf  := i.idf, on = 'word']
    tfs[, tf_idf   := tf * idf]

    setorder(tfs, cluster, -tf_idf)
    tfsel <- tfs[, head(.SD, n.tokens.max), cluster] # only consider top tokens

    ## ** Remove 1-grams that are part of n-grams within best tokens
    tfsel[, within_others := {
        words <- .SD[, word]
        sapply(words, function(w) any(grepl(w, setdiff(words, w), fixed = T)))
    }, cluster]
    tfsel <- tfsel[within_others == F]

    ## ** Get label for each cluster
    labels <- tfsel[, .(label = paste(head(word, n.tokens), collapse=sep)), cluster]

    labels <- merge(labels,
                    textclusters[, .(dens=mean(dens), n_txt = .N), cluster], by = 'cluster', sort=F)
    setorder(labels, -dens)
    
    labels[, cluster_i := .I]
    labels[cluster == 0L, cluster_i := 0L]

    ## ** Add coordinates (run umap on 2D if necessary)
    if (add.coords) {
        if (is.null(umap2d)) {
            umap2d <- readRDS(infiles[['um2d']])
        }
        umap2d[textclusters, cluster := i.cluster, on = 'text_id']
        clcoords <- umap2d[, .(x = mean(umap_v1), y = mean(umap_v2)), cluster]
        labels[clcoords, `:=`(x = i.x, y = i.y), on = 'cluster']
    }

    saveRDS(labels, replace.file(outfile))
    success(state)
    return(invisible(labels))
}
    

plot.clusters <- function(clusters=NULL, width=opt('plot.width'), height=opt('plot.height'),
                          infile = projfile(opt('clusters')),
                          outfile = projfile(opt('plot.file'))) {

    state <- check.state(clusters, width, height, infile, outfile = outfile, readfun = NULL)
    if (state$status == 0) return(invisible(state$output))

    if (is.null(clusters)) {
        if (!file.exists(infile))
            stop('Clusters not formed yet.')
        clusters <- readRDS(infile)
    }

    if (!all(c('x', 'y') %in% names(clusters))) {
        warning('Cluster coordinates not in data. Specify `add.coords=TRUE` in `label.clusters()` or set `make.map = T` in project.options. Not plotting.\n')
        return()
    }

    cat('Plotting clusters...\n')
    clusters[, lab := gsub('_', ' ', gsub(', ', '\n', label))]
    clusters[, col := fifelse(cluster != 0, rev(gplots::rich.colors(nrow(clusters))), '#999999FF')]

    library(ggplot2)
    library(ggrepel)

    g <- ggplot(clusters, aes(x = x, y = y, size = n_txt, label = lab, colour = col)) +
        geom_point() +
        scale_fill_identity() +
        geom_label_repel(size = 2, fill = NA, lineheight = 0.8) +
        theme_void() +
        theme(legend.position = 'none')
    
    ggsave(replace.file(outfile), g, width=width, height=height)
    success(state)
    return(invisible(g))
}


make.deck <- function(clusters=NULL, text_clusters=NULL, umap2d=NULL, corpus=NULL,
                      p.shown=opt('deck.p.shown'),
                      zoom = opt('deck.zoom'), width = opt('deck.width'), height = opt('deck.height'),
                      opacity = opt('deck.opacity'),
                      deck_labelling = opt('deck.labelling'),
                      infiles = c(clust = projfile(opt('clusters')),
                                  txtcl = projfile(opt('text.clusters')),
                                  um2d  = projfile(opt('embeddings.umap.2d')),
                                  corp  = projfile(opt('corpus.imported'))),
                      outfile = projfile(opt('deck.file'))) {

    state <- check.state(clusters, text_clusters, umap2d, corpus, p.shown, zoom, width,
                         height, opacity, deck_labelling, infiles,
                         outfile = outfile, readfun = NULL)
    if (state$status == 0) return(invisible(state$output))

    if (is.null(clusters)) {
        clusters <- readRDS(infiles[['clust']])
    }
    if (is.null(text_clusters)) {
        text_clusters <- readRDS(infiles[['txtcl']])
    }
    if (is.null(umap2d)) {
        umap2d <- readRDS(infiles[['um2d']])
    }
    if (is.null(corpus)) {
        corpus <- readRDS(infiles[['corp']])
    }
    if (p.shown < 1) {
        corpus <- corpus[sample(seq_len(.N), p.shown*.N)]
    }

    text_clusters[, text_id := as.integer(text_id)]
    corpus[text_clusters, cluster := i.cluster, on = 'text_id']
    umap2d[, text_id := as.integer(text_id)]
    corpus[umap2d, `:=`(x = i.umap_v1, y = i.umap_v2), on = 'text_id']

    clusters[, col := fifelse(cluster != 0, rev(gplots::rich.colors(nrow(clusters))), '#999999FF')]
    corpus[clusters, `:=`(cluster_i = i.cluster_i, cl_label = i.label, col = i.col), on = 'cluster']

    corpus[, lab := glue::glue(deck_labelling, .envir=.SD)]

    dat <- corpus[, .(x, y, lab, col)]
    dat <- dat[is.finite(x) & is.finite(y)]
    
    library(deckgl)
    properties <- list(
        getPosition = get_position('x', 'y'),
        getColor = get_color_to_rgb_array('col'),
        getFillColor = get_color_to_rgb_array('col'),
        getTooltip = JS("object =>`${object.lab}`")
    )

    xm <- dat[, median(x, na.rm=T)]
    ym <- dat[, median(y, na.rm=T)]

    deck <- deckgl(latitude = ym, longitude = xm, zoom = zoom, width=width, height=height,
                   style = list(background = "#F5F5F5")) %>%
        add_scatterplot_layer(data = dat,
                              properties = properties,
                              getRadius = 500,
                              radiusScale = 18,
                              radiusMinPixels = 3,
                              radiusMaxPixels = 10,
                              opacity = opacity
                              )

    htmlwidgets::saveWidget(deck, replace.file(basename(outfile)))
    invisible(replace.file(outfile))
    file.copy(basename(outfile), dirname(outfile), overwrite=T)
    success(state)
    return(deck)
}



make.deck.docs <- function(clusters=NULL, text_clusters=NULL, umap2d=NULL, corpus=NULL,
                      p.shown=opt('deck.p.shown'),
                      zoom = opt('deck.zoom'), width = opt('deck.width'), height = opt('deck.height'),
                      opacity = opt('deck.opacity'),
                      deck_labelling = opt('deck.labelling'),
                      infiles = c(clust = projfile(opt('clusters')),
                                  txtcl = projfile(opt('text.clusters')),
                                  um2d  = projfile(opt('embeddings.docs.umap.2d')),
                                  corp  = projfile(opt('corpus.imported'))),
                      outfile = projfile(opt('deck.docs.file'))) {
## clusters=NULL; text_clusters=NULL; umap2d=NULL; corpus=NULL; p.shown=opt('deck.p.shown'); zoom = opt('deck.zoom'); width = opt('deck.width'); height = opt('deck.height'); opacity = opt('deck.opacity'); deck_labelling = opt('deck.labelling'); infiles = c(clust = projfile(opt('clusters')), txtcl = projfile(opt('text.clusters')), um2d  = projfile(opt('embeddings.docs.umap.2d')), corp  = projfile(opt('corpus.imported'))); outfile = projfile(opt('deck.file'))

    state <- check.state(clusters, text_clusters, umap2d, corpus, p.shown, zoom, width,
                         height, opacity, deck_labelling, infiles,
                         outfile = outfile, readfun = NULL)
    if (state$status == 0) return(invisible(state$output))

    if (is.null(clusters)) {
        clusters <- readRDS(infiles[['clust']])
    }
    if (is.null(text_clusters)) {
        text_clusters <- readRDS(infiles[['txtcl']])
    }
    text_clusters[clusters, cluster_i := i.cluster_i, on = 'cluster']
    
    if (is.null(umap2d)) {
        umap2d <- readRDS(infiles[['um2d']])
    }
    if (is.null(corpus)) {
        corpus <- readRDS(infiles[['corp']])
    }
    if (p.shown < 1) {
        corpus <- corpus[sample(seq_len(.N), p.shown*.N)]
    }

    text_clusters[, text_id := as.integer(text_id)]
    text_clusters[corpus, text_group_id := i.text_group_id, on = 'text_id']
    tcl <- text_clusters[, .(.N, dens = max(dens)), .(text_group_id, cluster_i)]
    setorder(tcl, text_group_id, -N)
    doc_clusters <- tcl[, .(cluster_i = cluster_i[1L], dens = dens[1L]), text_group_id]
    
    corpus <- corpus[, .(text = paste(text, collapse='<br>')), .(text_group_id, asset_id, source)]
    corpus[doc_clusters, `:=`(cluster_i = i.cluster_i),
                            on = 'text_group_id']

    
    ## doc_clusters[clusters, col := i.col, on = 
    ## corpus[
    umap2d[, text_group_id := as.integer(text_group_id)]
    corpus[umap2d, `:=`(x = i.umap_v1, y = i.umap_v2), on = 'text_group_id']

    clusters[, col := fifelse(cluster != 0, rev(gplots::rich.colors(nrow(clusters))), '#999999FF')]
    corpus[clusters, `:=`(cl_label = i.label, col = i.col), on = 'cluster_i']

    corpus[, lab := glue::glue(deck_labelling, .envir=.SD)]

    dat <- corpus[, .(x, y, lab, col)]
    dat <- dat[is.finite(x) & is.finite(y)]
    
    library(deckgl)
    properties <- list(
        getPosition = get_position('x', 'y'),
        getColor = get_color_to_rgb_array('col'),
        getFillColor = get_color_to_rgb_array('col'),
        getTooltip = JS("object =>`${object.lab}`")
    )

    xm <- dat[, median(x, na.rm=T)]
    ym <- dat[, median(y, na.rm=T)]

    deck <- deckgl(latitude = ym, longitude = xm, zoom = zoom, width=width, height=height,
                   style = list(background = "#F5F5F5")) %>%
        add_scatterplot_layer(data = dat,
                              properties = properties,
                              getRadius = 500,
                              radiusScale = 18,
                              radiusMinPixels = 3,
                              radiusMaxPixels = 10,
                              opacity = opacity
                              )

    htmlwidgets::saveWidget(deck, replace.file(basename(outfile)))
    invisible(replace.file(outfile))
    file.copy(basename(outfile), dirname(outfile), overwrite=T)
    success(state)
    return(deck)
}





comparison <- function(projects, option.files='plot.file', tmpfold=tempdir(),
                       rmdfile=file.path(tmpfold, 'project-comparison.Rmd'),
                       htmlfile=file.path(tmpfold, 'project-comparison.html')) {

    library(data.table)
    library(knitr)
    library(ggplot2)

    rmd <- sprintf('---
title: Comparison of %s across projects
date: "%s"
output:
  rmdformats::downcute:
    lightbox: true
    thumbnails: false
    gallery: true
    toc_depth: 3
    toc_float:
      collapsed: false
      smooth_scoll: true
mode: selfcontained
---
\n', paste(option.files, collapse = ', '), Sys.time())

    cat(rmd, file=rmdfile)

    cat('\n\n# Projects compared\n\n', file = rmdfile, append = T)
    pdt <- as.data.table(projects, keep.rownames =T)
    tab <- kable(pdt, col.names = c('Folder', 'Label'), format = 'html', caption = 'Models being compared')
    cat(tab, file = rmdfile, append = T)

    ## ** Loop throught outputs to compare
    fil=option.files[1]
    for (fil in option.files) {
        
        cat(sprintf('\n\n# %s\n\n', fil), file = rmdfile, append=T)

        ## *** Loop through project folders
        proji=1
        for (proji in seq_along(projects)) {

            project <- projects[proji]
            cat(sprintf('\n\n## %s (%s)\n\n', project, names(project)), file = rmdfile, append = T)
            
            initialise.project(proj.dir = names(project))
            pfile <- projfile(opt(fil))

            if (!file.exists(pfile)) {
                warning('File `', pfile, '` not found')
                return()
            }

            ext <- tolower(sub('.*\\.(.*)$', '\\1', pfile))

            if (ext %in% c('svg', 'png', 'jpg')) {
                cat(sprintf('<img src="%s" />\n', pfile), file = rmdfile, append = T)
            } else if (ext %in% 'rds') {
                dat <- readRDS(pfile)
                if (is.data.frame(dat)) {
                    tab <- kable(dat, format = 'html')
                    cat(tab, file = rmdfile, append = T)
                } else {
                    s <- capture.output(str(tab))
                    cat(s, file = rmdfile, append = T)
                }
            } else if (ext %in% 'html') {
                cat(sprintf('<iframe width="1000" height="900" src="%s" frameborder="1" allowfullscreen></iframe>\n', pfile), file = rmdfile, append = T)
            } else {
                cat(pfile, file = rmdfile, append = T)
            }
        }

    }
    
    rmarkdown::render(input=rmdfile, output_file = htmlfile, clean=T)
    system(sprintf('xdg-open %s', htmlfile), wait=F)
    return(invisible(htmlfile))
}
