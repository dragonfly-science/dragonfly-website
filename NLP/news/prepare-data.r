library(data.table)
library(yaml)

dir.create('generated', showWarnings = F)

clean_text <- function(x) {
    txt_clean <- x
    txt_clean <- gsub('  +', ' ', txt_clean)
    txt_clean <- gsub('#[^\n]+\n', '\n', txt_clean)
    txt_clean <- gsub('[‘’]', '\'', txt_clean)
    txt_clean <- gsub('[”“]', '"', txt_clean)
    txt_clean <- gsub('\n+', ' ', txt_clean)
    txt_clean
}


## * NEWS

news <- dir('../../content/news', 'content.md', recursive = T, full.names = T)

md=news[50]
newsdata <- rbindlist(lapply(news, function(md) {
    cat(md, '\n')
    ori <- readLines(md)
    seps <- grep('^---', ori)
    ## stopifnot(length(seps) == 2L)
    summend <- grep('<!--more', ori)
    summ <- paste(ori[(seps[2]+1):(summend-1L)], collapse='\n')
    txt <- ori[(summend+1L):length(ori)]
    txt <- paste(txt, collapse='\n')
    yml <- read_yaml(text = ori[seps[1]:seps[2]])
    cbind(as.data.table(yml), data.table(file = basename(dirname(md)), summ = summ, txt = txt))
}), fill=T)

newsdata[, date := substr(file, 1, 10)]

## ** Text cleaning
newsdata[, txt_clean := clean_text(txt)]
newsdata[, id := .I]

saveRDS(newsdata, 'generated/news-data.rds')
