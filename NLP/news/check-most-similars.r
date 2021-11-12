library(data.table)

source('../rbol.r')
source('project-config.r')
source('project-functions.r')

options('mc.cores' = 6)

make.project(project.defaults, project.functions = project.functions, run.function = run)

simils <- jsonlite::read_json(projfile(opt('doc.simils')))
corp <- readRDS(projfile(opt('corpus.imported')))



test <- function() {
    i <- sample(length(simils),1)
    
    cat(sprintf('\n\n====== %s ======\n', names(simils)[i]))

    c <- corp[text_group_id == names(simils)[i]]
    cat(c$title, '\n')
    print(c$text)

    s=1
    for (s in seq_len(5L)) {
        cat('\n')
        c <- corp[text_group_id == simils[[i]][s]]
        cat(c$title, '\n')
        print(c$text)
    }
}

test()
