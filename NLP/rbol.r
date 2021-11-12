suppressPackageStartupMessages({
    library(digest)
})
    

## * PROJECT MANAGEMENT UTILITIES

opt <- function(what = NULL, default = NULL) {
    project.options <- getOption('PROJOPTIONS')
    if (is.null(what)) {
        return(project.options)
    } else {
        if (what %in% names(project.options)) {
            return(project.options[[what]])
        } else {
            return(default)
        }
    }
}

projfile <- function(filename) {
    file.path(getOption('PROJDIR'), ifelse(grepl('.', filename, fixed = T),
                                         filename, paste0(filename, '.rds')))
}

get.args <- function() {
    readRDS(projfile('function-arguments'))
}

get.project.defaults <- function() {
    optfile <- projfile('project-config.rdata')
    if (file.exists(optfile)) {
        load(optfile)
        return(project.defaults)
    } else {
        warning('Project not yet initialised')
        return(NULL)
    }
}

functions.order <- function(project.functions=NULL) {
    if (is.null(project.functions)) {
        if (file.exists(projfile('project-config.rdata'))) {
            load(projfile('project-config.rdata'), v=F)
        } else warning('Project not yet initialised')
    } 
    args <- vector("list", length(project.functions))
    names(args) <- project.functions
    return(args)
}

replace.file <- function(file) {
    if (file.exists(file)) {
        system(sprintf('rm %s', file))
        if (grepl('\\.html$', file)) {
            system(sprintf('rm -fr %s_files', sub('\\.html$', '', file)))
        }
    }
    return(file)
}

projects.diff <- function() {
    projects <- dir('.', '_[0-9a-f]{20,}$')
    prj=projects[1]
    opts <- rbindlist(lapply(projects, function(prj) {
        optfile <- file.path(prj, 'project-options.rds')
        if (file.exists(optfile)) {
            opts <- as.data.table(unlist(readRDS(optfile)), keep.rownames = T)
            setnames(opts, c('option', 'value'))
        } else opts <- data.table(option = character(0), value = character(0))
        opts <- cbind(project = prj, opts)
    }))
    nunvals <- opts[opts[, .(n=uniqueN(value)), .(option)][n>1, -'n'], on = 'option']
    setorder(nunvals, option, value, project)
    nunvals
    ## wide1 <- dcast(opts, project ~ option)
    ## wide2 <- dcast(opts, option ~ project)
    ## lst <- sapply(projects, function(prj) {
    ##     optfile <- file.path(prj, 'project-options.rds')
    ##     if (file.exists(optfile)) {
    ##         opts <- as.data.table(unlist(readRDS(optfile)), keep.rownames = T)
    ##     } else opts <- NULL
    ##     argfile <- file.path(prj, 'function-arguments.rds')
    ##     if (file.exists(argfile)) {
    ##         args <- as.data.table(unlist(readRDS(argfile)), keep.rownames = T)
    ##     } else args <- NULL
    ##     return(list(opts = opts, args = args))
    ## }, simplify = F)
    ## sha1 <- as.data.table(unlist(prevargs$args), keep.rownames = T)
    ##     setnames(sha1, c('what', 'prev'))

    ## unlist(sapply(lst, '[', 'opts'))
}


initialise.project <- function(proj.options=NULL, proj.dir=NULL, from.current=T) {

    if (is.null(proj.dir) & file.exists('.last-project') & from.current == T) {
        startdir <- readLines('.last-project', warn=F)
    } else if (!is.null(proj.dir)) {
        startdir <- proj.dir
    } else startdir <- NULL
    if (is.null(proj.options) & is.null(proj.dir) & file.exists('.last-project')) {
        proj.dir <- readLines('.last-project', warn=F)
    }
    if (is.null(proj.options)) {
        if (!is.null(proj.dir) && file.exists(file.path(proj.dir, 'project-options.rds'))) {
            proj.options <- readRDS(file.path(proj.dir, 'project-options.rds'))
        } else if (!is.null(getOption('PROJOPTIONS'))) {
            proj.options <- getOption('PROJOPTIONS')
        } else stop('Project options required for `initialise.project()`.\nTo get started, use `project.defaults()` and adapt the returned options.')
    }
    options('PROJOPTIONS' = proj.options)

    sha <- sha1(proj.options)
    projdir <- sprintf('%s_%s', opt('project.name'), sha)

    if (!is.null(proj.dir) && proj.dir != projdir)
        warning('Inconsistency found between project directory and associated options')
    options('PROJDIR' = projdir)
    
    if (!file.exists(projdir)) {
        cat(sprintf("Creating project directory %s as it doesn't exist...\n", projdir))
        dir.create(projdir)
        if (from.current & !is.null(startdir)) {
            fs <- dir(startdir)
            for (f in fs) {
                system(sprintf('ln -s -r -f %1$s/%2$s %3$s/%2$s', startdir, f, projdir))
            }
        } else {
            args <- functions.order()
            saveRDS(args, projfile('function-arguments'))
        }
        r <- saveRDS(proj.options, replace.file(projfile('project-options')))
    } else {
        cat(sprintf('Using %s as project directory.\n', projdir))
    }

    cat(projdir, file='.last-project')
    system(sprintf('rm -fr current-project  &&  ln -s %s current-project', projdir))
    
}
 
get.sha <- function(args) {
    if (!is.list(args))
        stop('`get.sha()` requires a list of arguments')

    fargs <- sapply(args, function(y) {
        if (is.function(y)) {
            return(sha1(y))
        } else {
            sapply(y, function(x) {
                if (is.character(x)  &&  file.exists(as.character(x))) {
                    sha <- sub('^([a-f0-9]+) .*', '\\1', system(sprintf('sha1sum %s', x), intern=T))
                } else {
                    sha <- sha1(x)
                }
                return(sha)
            })
        }
    }, simplify=F)

    return(fargs)
}

project.state <- function(opts) {
    argfile <- projfile('function-arguments')
    args <- readRDS(argfile)
    get.sha(opts)
}

reset.args <- function() {
    argfile <- projfile('function-arguments')
    args <- functions.order()
    saveRDS(args, replace.file(argfile))
}

set.proj.opt <- function(...) {
    newopts <- c(as.list(environment()), list(...))
    prevopts <- getOption('PROJOPTIONS')
    for (i in seq_along(newopts)) {
        prevopts[[names(newopts)[i]]] <- newopts[[i]]
    }
    options(PROJOPTIONS = prevopts)
    ## as.character(sys.call(-1)[1])    
}

get.state <- function(..., init = FALSE) {

    pos <- ifelse(as.character(sys.call(-1)[1]) == 'check.state', -1, 0)
    
    argfile <- projfile('function-arguments')

    if (file.exists(argfile) & init %in% F) {
        args <- readRDS(argfile)
    } else {
        args <- functions.order()
        saveRDS(args, replace.file(argfile))
    }
    
    ## Name of calling function
    fname <- as.character(sys.call(pos-1)[1])
    if (!(fname %in% names(args)))
        warning(sprintf('Function `%s` not in process list', fname))

    time <- Sys.time()

    ## ** Value of function arguments
    if (!is.null(names(list(...)[[1]]))) {
        fargs <- list(...)[[1]]
    } else {
        fargs <- c(as.list(environment(parent.frame(1-pos))), list(...))
        nms <- as.character(as.list(match.call(envir = parent.frame(2-pos), expand.dots = F)$`...`))[-1]
        if (getOption('DEBUG', 0) >= 2) {
            cat('\n--- Argument names:\n')
            print(nms)
        }
        nms <- setdiff(nms, 'init')
        names(fargs) <- nms
    }
    ## match.call(...)
    ## as.list(...)
    ## list(...)
    ## unlist(...)
    
    ## rlang::call_frame(...)
    ## list2(...)
    ## rlang::enquos(...)
    ## expr_print(...)
    ## match.call(expand.dots = T, envir = parent.frame(1-pos))
    ## match.call(call = sys.call(sys.parent(3)))
    ## as.list(environment(parent.frame(1-pos)))
    ## as.list(match.call(expand.dots = F))

    ## print(fargs)
    ## nms <- as.character(as.list(match.call(envir = parent.frame(2-pos))))[-1]

    ## ** Deal with suffix to identify several successive runs
    run_suff <- fargs$run_suff
    if (!is.null(run_suff)) {
        fname <- paste0(fname, run_suff)
    }
    fargs$run_suff <- NULL

    prevargs <- args[[fname]]
    newargs <- prevargs
    newargs$called_at <- time

    if (getOption('DEBUG', 0) >= 2) {
        cat('\n--- Arguments before sha:\n')
        print(fname)
        print(fargs)
    }
    ## ** Convert argument values to shas
    fargs <- get.sha(fargs)
    newargs$args <- fargs
    if (getOption('DEBUG', 0) >= 2) {
        cat('\n--- Arguments after sha:\n')
        print(fargs)
    }

    ## ** Diff of arguments
    if (!is.null(prevargs$args)) {
        sha1 <- as.data.table(unlist(prevargs$args), keep.rownames = T)
        setnames(sha1, c('what', 'prev'))
        sha1[grepl('file', what), what := sub('_[0-9a-f]{20,}', '', what)]
        sha2 <- as.data.table(unlist(fargs), keep.rownames = T)
        setnames(sha2, c('what', 'new'))
        sha2[grepl('file', what), what := sub('_[0-9a-f]{20,}', '', what)]
        shas <- merge(sha1, sha2, on = 'what', all = T)
        shas[grepl('infile', what) & !is.na(prev), prev := basename(prev)]
        shas[grepl('infile', what) & !is.na(new), new := basename(new)]
        diffs <- shas[(!is.na(prev) & is.na(new)) |
                      (is.na(prev) & !is.na(new)) |
                      prev != new]
    } else diffs <- data.table(what = character(0), prev = character(0), new = character(0))

    ## ** Check what changed
    change_reason <- NULL
    changed <- is.null(prevargs)
    if ((!is.null(prevargs$completed_at)  &&  !is.null(prevargs$called_at)  &&  prevargs$called_at > prevargs$completed_at) | is.null(prevargs$completed_at)) {
        changed <- TRUE
        change_reason <- c(change_reason, 'Task not completed')
    }
    if (nrow(diffs) > 0) {
        changed <- TRUE
        change_reason <- c(change_reason, 'Some project options differ')
        if (getOption('DEBUG', 0) >= 1) {
            cat('\n--- Diffs:\n')
            print(diffs)
        }
    }
    parameters_changed <- nrow(diffs[!grepl('file', what)]) > 0

    if (getOption('DEBUG', 0) >= 2) {
        cat('Parameters changed =', parameters_changed, '\n')
    }

    if (getOption('DEBUG', 0) >= 2) {
        cat('\n--- prevargs:\n')
        str(prevargs)
        cat('\n--- fargs:\n')
        str(fargs)
    }

    if (!is.null(change_reason) & getOption('DEBUG', 0) >= 1) {
        cat(sprintf('\n--- `%s`: Execute - %s\n', fname, paste(change_reason, collapse=', ')))
    }
    args[[fname]] <- newargs

    if (parameters_changed) {
        proj.options <- opt()
        sha <- sha1(proj.options)
        projdir <- sprintf('%s_%s', opt('project.name'), sha)
        currsha <- sub('.*_([0-9a-f]+)$', '\\1', getOption('PROJDIR'))
        if (currsha != sha) {
            initialise.project(proj.options)            
        }
    }
    
    return(list(fname = fname, changed = changed, parameters_changed = parameters_changed,
                prevargs = prevargs, newargs = fargs, diffs = diffs, args = args))
}


check.state <- function(..., outfile, readfun = readRDS) {
    argnms <- as.character(match.call(expand.dots = F)$`...`)
    args <- list(...)
    names(args) <- argnms
    
    state <- get.state(args)

    if (grepl('\\.json$', outfile)) {
        readfun <- jsonlite::read_json
    }
    if (!grepl('\\.rds$|\\.RDS', outfile) & !is.null(readfun)) {
        readfun <- readLines
    }
    fname <- state$fname
    cat(sprintf('%s - `%s`: ', Sys.time(), fname))
    if (getOption('DEBUG', 0) >= 2)
        print(state)
    if (!state$changed & !(getOption('FORCE',F) %in% TRUE)) {
        if (!is.null(readfun)) {
            out <- readfun(outfile)
        } else out <- outfile
        cat('No changes to inputs. Skipped.\n')
        success(state)
        res <- list(output = out, status = 0)
        return(invisible(res))
    } else {
        cat('running...\n')
        res <- list(output = state, status = 1)
        return(invisible(res))
    }
}


success <- function(state) {
    if (getOption('DEBUG', 0) >= 2)
        print(state)
    
    if (!is.null(state)) {
        args <- state$output$args
        if (!is.null(args)) {
            fname <- state$output$fname
            time <- Sys.time()
            if (!(fname %in% names(args)))
                warning(sprintf('function `%s` not in process list', fname))
            args[[fname]]$completed_at <- time
            saveRDS(args, replace.file(projfile('function-arguments')))
        }
    }
    return(invisible(NULL))
}


label.projects <- function(projlabels=NULL) {
    labfile <- 'project-labels.rds'
    if (file.exists(labfile)) {
        labs <- readRDS(labfile)
    } else labs <- character(0)

    if (is.null(projlabels))
        return(labs)
    
    vals <- projlabels
    nms <- names(projlabels)
    if (is.null(nms)) stop('`projlabels` needs to be a named character vector')

    for (i in seq_along(vals)) {
        labs[[nms[i]]] <- vals[i]
    }
    saveRDS(labs, labfile)
}



## * TEST

make.project <- function(project.defaults, project.functions, run.function) {
    run <- run.function
    if (!('project.name' %in% names(project.defaults)))
        project.defaults$project.name <- 'analysis'
    initialise.project(project.defaults)
    save(project.defaults,
         project.functions,
         run, file = projfile('project-config.rdata'))
}

