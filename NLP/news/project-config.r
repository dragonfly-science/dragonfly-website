## * PROJECT CONFIG

project.defaults <- list(
    ## import.corpus()
    project.name         = 'unsupervised-text-analysis',
    corpus.original      = 'generated/news-data.rds',
    text.var             = 'txt',
    id.var               = 'id',
    group.id.var         = 'file',
    covariates           = 'ALL',
    corpus.imported      = 'corpus',
    text.id.lookup         = 'text-id-lookup',
    ## preclean.corpus()
    rules                = c('"—', '" —'),
    corpus.precleaned    = 'corpus-precleaned',
    ## parse.corpus()
    consolidate.entities = TRUE,
    parsed.corpus        = 'parsed-corpus',
    parsed.corpus.dt     = 'parsed-corpus-dt',
    entities             = 'entities',
    ## consolidate.entity()
    parsed.corpus.cons   = 'parsed-corpus-consolidated',
    ## reform.corpus()
    reformed.corpus      = 'corpus-from-parsed-consolidated',
    ## unsupervised.training()
    modeltype            = "skipgram",
    loss                 = "hs",
    lr                   = 0.01,
    lrUpdate             = 100,
    dim                  = 300,
    ws                   = 10,
    epoch                = 5,
    minCount             = 1,
    neg                  = 5,
    wordNgrams           = 4,
    bucket               = 2e+06,
    minn                 = 3,
    maxn                 = 6,
    t                    = 1e-04,
    label                = "__lab__",
    verbose              = 2,
    pretrained.vec       = '/data/wiki-news-300d-1M.vec',
    model.file           = 'unsupervised_model.bin',
    ## tfidf()
    text.tfidf           = 'text-tf-idf',
    ## aggregate.embeddings()
    aggregate.method     = 'basic',
    embeddings           = 'text-embeddings',
    embeddings.docs      = 'doc-embeddings',
    ## calc.distances()
    doc.distances        = 'doc-distances',
    ## most.similar()
    doc.simils           = 'most-similar-documents.json',
    ## umap.plot()
    umap.plot            = 'umap-plot.html',
    ## make.tree()
    square.edges         = TRUE,
    tree                 = 'tree.html',
    ## make.tree2()
    tree2                = 'tree2.html',
    ## do.umap()
    dims                 = 10L,
    umap.pkg             = 'uwot',
    umap.n.neighbours    = 5L,
    umap.n.epochs        = 500L,
    umap.spread          = 1,
    normalise            = TRUE,
    embeddings.umap      = 'text-embeddings-umap',
    ## clustering()
    eps                  = NULL,
    text.clusters        = 'text-embeddings-clusters',
    ## umap.2d()
    embeddings.umap.2d   = 'text-embeddings-umap-2d',
    embeddings.docs.umap.2d   = 'doc-embeddings-umap-2d',
    ## label.clusters()
    create.map           = TRUE,
    max.ngram            = 4L,
    lab.n.tokens         = 5L,
    lab.n.tokens.max     = 20L,
    lab.sep              = ', ',
    clusters             = 'clusters-with-labels',
    ## plot.clusters()
    plot.width           = 10,
    plot.height          = 10,
    plot.file            = 'clusters.svg',
    ## make.deck()
    deck.p.shown         = 1,
    deck.zoom            = 3,
    deck.width           = 1400,
    deck.height          = 1000,
    deck.opacity         = 0.6,
    deck.labelling       = '{text_group_id}<br>Cluster {cluster_i}<br>{cl_label}<br><br>{text}',
    deck.file            = 'deck-map.html',
    deck.docs.file       = 'deck-docs-map.html'
)


project.functions <- c('import.corpus', 'preclean.corpus', 'parse.corpus',
                       'consolidate.entity', 'reform.corpus', 'unsupervised.training',
                       'tfidf', 'aggregate.embeddings', 'calc.distances', 'most.similar',
                       'umap.plot', 'make.tree', 'make.tree2',
                       'do.umap', 'clustering', 'do.umap_2d',
                       'label.clusters', 'plot.clusters', 'make.deck')


run <- function(proj.options = opt()) {
    initialise.project(proj.options)

    import.corpus()
    preclean.corpus()
    parse.corpus()
    reform.corpus()
    unsupervised.training()
    tfidf()
    aggregate.embeddings()
    calc.distances()
    most.similar()
    umap.plot()
    make.tree()
    make.tree2()
    do.umap()
    clustering()
    do.umap.2d(dims = 2L)
    aggregate.embeddings()
    do.umap()
    label.clusters()
    plot.clusters()
    deck <- make.deck()
    return(invisible(deck))
}

