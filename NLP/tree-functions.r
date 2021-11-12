
## * Assign number of children to each edge (from "to" node)
nchild2edges <- function(tedges, from.node = NULL) {
    if (is.null(from.node))
        from.node <- setdiff(tedges$from, tedges$to)
    tedges[, nchildren := NA_integer_]

    children <- tedges[from %chin% from.node]
    while(nrow(children)) {
        nchild <- children[, .N, from]
        tedges[nchild, nchildren := i.N, on = c('to' = 'from')]
        children <- tedges[from %chin% children$to]
    }
    return(invisible(tedges))
}

get.root <- function(tedges) {
    setdiff(tedges$from, tedges$to)
}

## * Assign the distance to root to each edge
dist2root <- function(tedges, from.node = NULL) {
    stopifnot(all(c('dist', 'from', 'to') %in% names(tedges)))

    if (is.null(from.node))
        from.node <- setdiff(tedges$from, tedges$to)

    if (is.null(key(tedges)) || key(tedges) != 'from')
        setkey(tedges, from)
    
    tedges[, cumdist := 0]
    i <- 1L
    children <- tedges[from %in% from.node]
    while(nrow(children)) {
        tedges[from %in% children$from, `:=`(cumdist = cumdist + dist, nthnode = i)]
        prevchildren <- tedges[from %in% children$from]
        children <- tedges[from %in% children$to]
        tedges[prevchildren, cumdist := i.cumdist, on = c('from' = 'to')]
        i <- i + 1L
    }
    return(invisible(tedges))
    
}

children_unique_vals <- function(tedges, var) {

    tedges[, cladevar := get(var)]
    tedges[, cladestart := F]
    ## if (is.null(key(tedges)) || key(tedges) != 'from')
    ##     setkey(tedges, from)

    naval <- fcase(
        tedges[, is.character(get(var))], NA_character_,
        tedges[, is.integer(get(var))], NA_integer_,
        tedges[, is.numeric(get(var))], NA_real_,
        default = NA
    )
        
    getun <- function(x) {
        vs <- unique(setdiff(x, NA))
        if (length(vs) == 1L) {
            return(vs)
        } else return('multiple')
    }

    tedges[, uniquevals_children := get(var)]

    sel <- tedges[nthnode == max(nthnode)]
    uns <- sel[, .(uniquevals_children = getun(uniquevals_children)), from]
    tedges[uns, uniquevals_children := i.uniquevals_children, on = c('to' = 'from')]

    for (nn in (max(tedges$nthnode)-1):1L) {
        sel <- tedges[nthnode == nn]
        uns <- sel[, .(uniquevals_children = getun(uniquevals_children)), from]
        sel[uns, uniquevals_children_new := i.uniquevals_children, on = 'from']
        cladestarts <- sel[uniquevals_children_new == 'multiple' & uniquevals_children != 'multiple']
        tedges[cladestarts, cladestart := T, on = c('from' = 'to')]
        tedges[uns, uniquevals_children := i.uniquevals_children, on = c('to' = 'from')]
    }

}


## * Create edges data.table from phylo tree, and join tips data
get.edges <- function(tree) {
    tedges <- as.data.table(tree$edge)
    setnames(tedges, c('from', 'to'))
    tedges[, eid := .I]
    tedges[, dist := tree$edge.length]
    ttips <- get.tips(tree)
    tedges[, to.tip := V2 %in% ttips$id]
    tedges <- merge(tedges, ttips, by.x = 'V2', by.y = 'id', all.x = T, all.y = F, sort = F)
    setnames(tedges, c('V1', 'V2'), c('from', 'to'))
    setcolorder(tedges, c('from', 'to'))
    nchild2edges(tedges)
    dist2root(tedges)
    tedges
}


## * Extract clade of same trait, given a tip id, from edges data.table
common.trait.clade <- function(tedges, tip, var) {

    i <- 0L
    anc <- tedges[to == tip]
    val <- anc[, get(var)]
    if (is.na(val))
        stop('Need a tip with a non-NA value to start from')
    
    anc[, lvl := i]
    res <- anc

    sibs <- get.children(tedges, anc$from)
    cont <- sibs[, all(get(var) %in% c(NA, val))]

    while(cont) {
        sibs <- sibs[!res, on = 'to']
        sibs[, lvl := i]
        res <- rbind(res, sibs)
        i <- i + 1L
        anc <- tedges[to == anc$from]
        sibs <- get.children(tedges, anc$from)
        cont <- sibs[, all(get(var) %in% c(NA, val))]
    }

    return(res)
}



update.tree <- function(tedges) {
    tedges <- nchild2edges(tedges)
    tedges <- dist2root(tedges)
    tedges[, to.tip := fifelse(is.na(nchildren), T, F)]
    return(invisible(tedges))
}



## x=tree
## type = "fan"; use.edge.length = TRUE; node.pos = NULL; 
## show.tip.label = FALSE; show.node.label = FALSE; edge.color = "grey50"; 
## edge.width = 1; edge.lty = 1; font = 3; cex = par("cex"); 
## adj = NULL; srt = 0; no.margin = TRUE; root.edge = FALSE; 
## label.offset = 0; underscore = FALSE; x.lim = NULL; y.lim = NULL; 
## direction = "rightwards"; lab4ut = NULL; tip.color = "red"; 
## plot = TRUE; rotate.tree = 0; open.angle = 0; node.depth = 1; 
## align.tip.label = FALSE
## * Adaptation of ape::plot.phylo() to return the coordinates
plot2 <- function (x, type = "phylogram", use.edge.length = TRUE, node.pos = NULL, 
    show.tip.label = TRUE, show.node.label = FALSE, edge.color = "black", 
    edge.width = 1, edge.lty = 1, font = 3, cex = par("cex"), 
    adj = NULL, srt = 0, no.margin = FALSE, root.edge = FALSE, 
    label.offset = 0, underscore = FALSE, x.lim = NULL, y.lim = NULL, 
    direction = "rightwards", lab4ut = NULL, tip.color = "black", 
    plot = TRUE, rotate.tree = 0, open.angle = 0, node.depth = 1, 
    align.tip.label = FALSE, ...) {

    Ntip <- length(x$tip.label)

    if (Ntip < 2) {
        warning("found less than 2 tips in the tree")
        return(NULL)
    }
    .nodeHeight <- function(edge, Nedge, yy) .C(node_height, 
        as.integer(edge[, 1]), as.integer(edge[, 2]), as.integer(Nedge), 
        as.double(yy))[[4]]
    .nodeDepth <- function(Ntip, Nnode, edge, Nedge, node.depth) .C(node_depth, 
        as.integer(Ntip), as.integer(edge[, 1]), as.integer(edge[, 
            2]), as.integer(Nedge), double(Ntip + Nnode), as.integer(node.depth))[[5]]
    .nodeDepthEdgelength <- function(Ntip, Nnode, edge, Nedge, 
        edge.length) .C(node_depth_edgelength, as.integer(edge[, 
        1]), as.integer(edge[, 2]), as.integer(Nedge), as.double(edge.length), 
        double(Ntip + Nnode))[[5]]
    Nedge <- dim(x$edge)[1]
    Nnode <- x$Nnode
    if (any(x$edge < 1) || any(x$edge > Ntip + Nnode)) 
        stop("tree badly conformed; cannot plot. Check the edge matrix.")
    ROOT <- Ntip + 1
    type <- match.arg(type, c("phylogram", "cladogram", "fan", 
        "unrooted", "radial"))
    direction <- match.arg(direction, c("rightwards", "leftwards", 
        "upwards", "downwards"))
    if (is.null(x$edge.length)) {
        use.edge.length <- FALSE
    } else {
        if (use.edge.length && type != "radial") {
            tmp <- sum(is.na(x$edge.length))
            if (tmp) {
                warning(paste(tmp, "branch length(s) NA(s): branch lengths ignored in the plot"))
                use.edge.length <- FALSE
            }
        }
    }
    if (is.numeric(align.tip.label)) {
        align.tip.label.lty <- align.tip.label
        align.tip.label <- TRUE
    } else {
        if (align.tip.label) 
            align.tip.label.lty <- 3
    }
    if (align.tip.label) {
        if (type %in% c("unrooted", "radial") || !use.edge.length || 
            is.ultrametric(x)) 
            align.tip.label <- FALSE
    }
    if (type %in% c("unrooted", "radial") || !use.edge.length || 
        is.null(x$root.edge) || !x$root.edge) 
        root.edge <- FALSE
    phyloORclado <- type %in% c("phylogram", "cladogram")
    horizontal <- direction %in% c("rightwards", "leftwards")
    xe <- x$edge
    if (phyloORclado) {
        phyOrder <- attr(x, "order")
        if (is.null(phyOrder) || phyOrder != "cladewise") {
            x <- reorder(x)
            if (!identical(x$edge, xe)) {
                ereorder <- match(x$edge[, 2], xe[, 2])
                if (length(edge.color) > 1) {
                  edge.color <- rep(edge.color, length.out = Nedge)
                  edge.color <- edge.color[ereorder]
                }
                if (length(edge.width) > 1) {
                  edge.width <- rep(edge.width, length.out = Nedge)
                  edge.width <- edge.width[ereorder]
                }
                if (length(edge.lty) > 1) {
                  edge.lty <- rep(edge.lty, length.out = Nedge)
                  edge.lty <- edge.lty[ereorder]
                }
            }
        }
        yy <- numeric(Ntip + Nnode)
        TIPS <- x$edge[x$edge[, 2] <= Ntip, 2]
        yy[TIPS] <- 1:Ntip
    }
    z <- reorder(x, order = "postorder")
    if (phyloORclado) {
        if (is.null(node.pos)) 
            node.pos <- if (type == "cladogram" && !use.edge.length) 
                2
            else 1
        if (node.pos == 1) 
            yy <- .nodeHeight(z$edge, Nedge, yy)
        else {
            ans <- .C(node_height_clado, as.integer(Ntip), as.integer(z$edge[, 
                1]), as.integer(z$edge[, 2]), as.integer(Nedge), 
                double(Ntip + Nnode), as.double(yy))
            xx <- ans[[5]] - 1
            yy <- ans[[6]]
        }
        if (!use.edge.length) {
            if (node.pos != 2) 
                xx <- .nodeDepth(Ntip, Nnode, z$edge, Nedge, 
                  node.depth) - 1
            xx <- max(xx) - xx
        }
        else {
            xx <- .nodeDepthEdgelength(Ntip, Nnode, z$edge, Nedge, 
                z$edge.length)
        }
    } else {
        twopi <- 2 * pi
        rotate.tree <- twopi * rotate.tree/360
        if (type != "unrooted") {
            TIPS <- x$edge[which(x$edge[, 2] <= Ntip), 2]
            xx <- seq(0, twopi * (1 - 1/Ntip) - twopi * open.angle/360, 
                length.out = Ntip)
            theta <- double(Ntip)
            theta[TIPS] <- xx
            theta <- c(theta, numeric(Nnode))
        }
        switch(type, fan = {
            theta <- .nodeHeight(z$edge, Nedge, theta)
            if (use.edge.length) {
                r <- .nodeDepthEdgelength(Ntip, Nnode, z$edge, 
                  Nedge, z$edge.length)
            } else {
                r <- .nodeDepth(Ntip, Nnode, z$edge, Nedge, node.depth)
                r <- 1/r
            }
            theta <- theta + rotate.tree
            if (root.edge) r <- r + x$root.edge
            xx <- r * cos(theta)
            yy <- r * sin(theta)
        }, unrooted = {
            nb.sp <- .nodeDepth(Ntip, Nnode, z$edge, Nedge, node.depth)
            XY <- if (use.edge.length) unrooted.xy(Ntip, Nnode, 
                z$edge, z$edge.length, nb.sp, rotate.tree) else unrooted.xy(Ntip, 
                Nnode, z$edge, rep(1, Nedge), nb.sp, rotate.tree)
            xx <- XY$M[, 1] - min(XY$M[, 1])
            yy <- XY$M[, 2] - min(XY$M[, 2])
        }, radial = {
            r <- .nodeDepth(Ntip, Nnode, z$edge, Nedge, node.depth)
            r[r == 1] <- 0
            r <- 1 - r/Ntip
            theta <- .nodeHeight(z$edge, Nedge, theta) + rotate.tree
            xx <- r * cos(theta)
            yy <- r * sin(theta)
        })
    }
    if (phyloORclado) {
        if (!horizontal) {
            tmp <- yy
            yy <- xx
            xx <- tmp - min(tmp) + 1
        }
        if (root.edge) {
            if (direction == "rightwards") 
                xx <- xx + x$root.edge
            if (direction == "upwards") 
                yy <- yy + x$root.edge
        }
    }
    if (no.margin) 
        par(mai = rep(0, 4))
    if (show.tip.label) 
        nchar.tip.label <- nchar(x$tip.label)
    max.yy <- max(yy)
    getLimit <- function(x, lab, sin, cex) {
        s <- strwidth(lab, "inches", cex = cex)
        if (any(s > sin)) 
            return(1.5 * max(x))
        Limit <- 0
        while (any(x > Limit)) {
            i <- which.max(x)
            alp <- x[i]/(sin - s[i])
            Limit <- x[i] + alp * s[i]
            x <- x + alp * s
        }
        Limit
    }
    if (is.null(x.lim)) {
        if (phyloORclado) {
            if (horizontal) {
                xx.tips <- xx[1:Ntip]
                if (show.tip.label) {
                  pin1 <- par("pin")[1]
                  tmp <- getLimit(xx.tips, x$tip.label, pin1, 
                    cex)
                  tmp <- tmp + label.offset
                }
                else tmp <- max(xx.tips)
                x.lim <- c(0, tmp)
            }
            else x.lim <- c(1, Ntip)
        } else switch(type, fan = {
            if (show.tip.label) {
                offset <- max(nchar.tip.label * 0.018 * max.yy * 
                  cex)
                x.lim <- range(xx) + c(-offset, offset)
            } else x.lim <- range(xx)
        }, unrooted = {
            if (show.tip.label) {
                offset <- max(nchar.tip.label * 0.018 * max.yy * 
                  cex)
                x.lim <- c(0 - offset, max(xx) + offset)
            } else x.lim <- c(0, max(xx))
        }, radial = {
            if (show.tip.label) {
                offset <- max(nchar.tip.label * 0.03 * cex)
                x.lim <- c(-1 - offset, 1 + offset)
            } else x.lim <- c(-1, 1)
        })
    } else if (length(x.lim) == 1) {
        x.lim <- c(0, x.lim)
        if (phyloORclado && !horizontal) 
            x.lim[1] <- 1
        if (type %in% c("fan", "unrooted") && show.tip.label) 
            x.lim[1] <- -max(nchar.tip.label * 0.018 * max.yy * 
                cex)
        if (type == "radial") 
            x.lim[1] <- if (show.tip.label) 
                -1 - max(nchar.tip.label * 0.03 * cex)
            else -1
    }
    if (phyloORclado && direction == "leftwards") 
        xx <- x.lim[2] - xx
    if (is.null(y.lim)) {
        if (phyloORclado) {
            if (horizontal) 
                y.lim <- c(1, Ntip)
            else {
                pin2 <- par("pin")[2]
                yy.tips <- yy[1:Ntip]
                if (show.tip.label) {
                  tmp <- getLimit(yy.tips, x$tip.label, pin2, 
                    cex)
                  tmp <- tmp + label.offset
                }
                else tmp <- max(yy.tips)
                y.lim <- c(0, tmp)
            }
        } else switch(type, fan = {
            if (show.tip.label) {
                offset <- max(nchar.tip.label * 0.018 * max.yy * 
                  cex)
                y.lim <- c(min(yy) - offset, max.yy + offset)
            } else y.lim <- c(min(yy), max.yy)
        }, unrooted = {
            if (show.tip.label) {
                offset <- max(nchar.tip.label * 0.018 * max.yy * 
                  cex)
                y.lim <- c(0 - offset, max.yy + offset)
            } else y.lim <- c(0, max.yy)
        }, radial = {
            if (show.tip.label) {
                offset <- max(nchar.tip.label * 0.03 * cex)
                y.lim <- c(-1 - offset, 1 + offset)
            } else y.lim <- c(-1, 1)
        })
    } else if (length(y.lim) == 1) {
        y.lim <- c(0, y.lim)
        if (phyloORclado && horizontal) 
            y.lim[1] <- 1
        if (type %in% c("fan", "unrooted") && show.tip.label) 
            y.lim[1] <- -max(nchar.tip.label * 0.018 * max.yy * 
                             cex)
        if (type == "radial") 
            y.lim[1] <- if (show.tip.label) 
                            -1 - max(nchar.tip.label * 0.018 * max.yy * cex)
                        else -1
    }
    if (phyloORclado && direction == "downwards") 
        yy <- y.lim[2] - yy
    if (phyloORclado && root.edge) {
        if (direction == "leftwards") 
            x.lim[2] <- x.lim[2] + x$root.edge
        if (direction == "downwards") 
            y.lim[2] <- y.lim[2] + x$root.edge
    }
    asp <- fifelse(type %in% c("fan", "radial", "unrooted"), 1, NA_integer_)
    plot.default(0, type = "n", xlim = x.lim, ylim = y.lim, xlab = "", 
        ylab = "", axes = FALSE, asp = asp, ...)
    if (plot) {
        if (is.null(adj)) 
            adj <- fifelse(phyloORclado && direction == "leftwards", 1, 0)
        if (phyloORclado && show.tip.label) {
            MAXSTRING <- max(strwidth(x$tip.label, cex = cex))
            loy <- 0
            if (direction == "rightwards") {
                lox <- label.offset + MAXSTRING * 1.05 * adj
            }
            if (direction == "leftwards") {
                lox <- -label.offset - MAXSTRING * 1.05 * (1 - adj)
            }
            if (!horizontal) {
                psr <- par("usr")
                MAXSTRING <- MAXSTRING * 1.09 * (psr[4] - psr[3])/(psr[2] - psr[1])
                loy <- label.offset + MAXSTRING * 1.05 * adj
                lox <- 0
                srt <- 90 + srt
                if (direction == "downwards") {
                    loy <- -loy
                    srt <- 180 + srt
                }
            }
        }
        if (type == "phylogram") {
            phylogram.plot(x$edge, Ntip, Nnode, xx, yy, horizontal, 
                           edge.color, edge.width, edge.lty)
        } else {
            if (type == "fan") {
                ereorder <- match(z$edge[, 2], x$edge[, 2])
                if (length(edge.color) > 1) {
                    edge.color <- rep(edge.color, length.out = Nedge)
                    edge.color <- edge.color[ereorder]
                }
                if (length(edge.width) > 1) {
                    edge.width <- rep(edge.width, length.out = Nedge)
                    edge.width <- edge.width[ereorder]
                }
                if (length(edge.lty) > 1) {
                    edge.lty <- rep(edge.lty, length.out = Nedge)
                    edge.lty <- edge.lty[ereorder]
                }
                circular.plot(z$edge, Ntip, Nnode, xx, yy, theta, 
                              r, edge.color, edge.width, edge.lty)
            } else {
                cladogram.plot(x$edge, xx, yy, edge.color, edge.width, edge.lty)
            }
        }
        if (root.edge) {
            rootcol <- fifelse(length(edge.color) == 1, edge.color, 'black')
            rootw <- fifelse(length(edge.width) == 1, edge.width, 1)
            rootlty <- fifelse(length(edge.lty) == 1, edge.lty, 1)
            if (type == "fan") {
                tmp <- polar2rect(x$root.edge, theta[ROOT])
                segments(0, 0, tmp$x, tmp$y, col = rootcol, lwd = rootw, 
                         lty = rootlty)
            } else {
                switch(direction,
                       rightwards = segments(0, yy[ROOT], 
                                             x$root.edge, yy[ROOT], col = rootcol, lwd = rootw, 
                                             lty = rootlty), leftwards = segments(xx[ROOT], 
                                                                                  yy[ROOT], xx[ROOT] + x$root.edge, yy[ROOT], 
                                                                                  col = rootcol, lwd = rootw, lty = rootlty), 
                       upwards = segments(xx[ROOT], 0, xx[ROOT], x$root.edge, 
                                          col = rootcol, lwd = rootw, lty = rootlty), 
                       downwards = segments(xx[ROOT], yy[ROOT], xx[ROOT], 
                                            yy[ROOT] + x$root.edge, col = rootcol, lwd = rootw, 
                                            lty = rootlty))
            }
        }
        if (show.tip.label) {
            if (is.expression(x$tip.label)) 
                underscore <- TRUE
            if (!underscore) 
                x$tip.label <- gsub("_", " ", x$tip.label)
            if (phyloORclado) {
                if (align.tip.label) {
                    xx.tmp <- switch(direction, rightwards = max(xx[1:Ntip]), 
                                     leftwards = min(xx[1:Ntip]), upwards = xx[1:Ntip], 
                                     downwards = xx[1:Ntip])
                    yy.tmp <- switch(direction, rightwards = yy[1:Ntip], 
                                     leftwards = yy[1:Ntip], upwards = max(yy[1:Ntip]), 
                                     downwards = min(yy[1:Ntip]))
                    segments(xx[1:Ntip], yy[1:Ntip], xx.tmp, yy.tmp, 
                             lty = align.tip.label.lty)
                }
                else {
                    xx.tmp <- xx[1:Ntip]
                    yy.tmp <- yy[1:Ntip]
                }
                text(xx.tmp + lox, yy.tmp + loy, x$tip.label, 
                     adj = adj, font = font, srt = srt, cex = cex, 
                     col = tip.color)
            } else {
                angle <- if (type == "unrooted") 
                             XY$axe
                         else atan2(yy[1:Ntip], xx[1:Ntip])
                lab4ut <- if (is.null(lab4ut)) {
                              if (type == "unrooted") 
                                  "horizontal"
                              else "axial"
                          }
                          else match.arg(lab4ut, c("horizontal", "axial"))
                xx.tips <- xx[1:Ntip]
                yy.tips <- yy[1:Ntip]
                if (label.offset) {
                    xx.tips <- xx.tips + label.offset * cos(angle)
                    yy.tips <- yy.tips + label.offset * sin(angle)
                }
                if (lab4ut == "horizontal") {
                    y.adj <- x.adj <- numeric(Ntip)
                    sel <- abs(angle) > 0.75 * pi
                    x.adj[sel] <- -strwidth(x$tip.label)[sel] * 
                        1.05
                    sel <- abs(angle) > pi/4 & abs(angle) < 0.75 * 
                        pi
                    x.adj[sel] <- -strwidth(x$tip.label)[sel] * 
                        (2 * abs(angle)[sel]/pi - 0.5)
                    sel <- angle > pi/4 & angle < 0.75 * pi
                    y.adj[sel] <- strheight(x$tip.label)[sel]/2
                    sel <- angle < -pi/4 & angle > -0.75 * pi
                    y.adj[sel] <- -strheight(x$tip.label)[sel] * 
                        0.75
                    text(xx.tips + x.adj * cex, yy.tips + y.adj * 
                                                cex, x$tip.label, adj = c(adj, 0), font = font, 
                         srt = srt, cex = cex, col = tip.color)
                } else {
                    if (align.tip.label) {
                        POL <- rect2polar(xx.tips, yy.tips)
                        POL$r[] <- max(POL$r)
                        REC <- polar2rect(POL$r, POL$angle)
                        xx.tips <- REC$x
                        yy.tips <- REC$y
                        segments(xx[1:Ntip], yy[1:Ntip], xx.tips, 
                                 yy.tips, lty = align.tip.label.lty)
                    }
                    if (type == "unrooted") {
                        adj <- abs(angle) > pi/2
                        angle <- angle * 180/pi
                        angle[adj] <- angle[adj] - 180
                        adj <- as.numeric(adj)
                    } else {
                        s <- xx.tips < 0
                        angle <- angle * 180/pi
                        angle[s] <- angle[s] + 180
                        adj <- as.numeric(s)
                    }
                    font <- rep(font, length.out = Ntip)
                    tip.color <- rep(tip.color, length.out = Ntip)
                    cex <- rep(cex, length.out = Ntip)
                    for (i in 1:Ntip) text(xx.tips[i], yy.tips[i], 
                                           x$tip.label[i], font = font[i], cex = cex[i], 
                                           srt = angle[i], adj = adj[i], col = tip.color[i])
                }
            }
        }
        if (show.node.label) 
            text(xx[ROOT:length(xx)] + label.offset, yy[ROOT:length(yy)], 
                 x$node.label, adj = adj, font = font, srt = srt, 
                 cex = cex)
    }
    L <- list(type = type, use.edge.length = use.edge.length, 
        node.pos = node.pos, node.depth = node.depth, show.tip.label = show.tip.label, 
        show.node.label = show.node.label, font = font, cex = cex, 
        adj = adj, srt = srt, no.margin = no.margin, label.offset = label.offset, 
        x.lim = x.lim, y.lim = y.lim, direction = direction, 
        tip.color = tip.color, Ntip = Ntip, Nnode = Nnode, root.time = x$root.time, 
        align.tip.label = align.tip.label, coords = list(edge = xe, xx = xx, yy = yy))
    assign("last_plot.phylo", c(L, list(edge = xe, xx = xx, yy = yy)), 
        envir = .PlotPhyloEnv)
    invisible(L)
}



get.children <- function(tedges, from.node = NULL) {
    if (is.null(from.node))
        from.node <- setdiff(tedges$from , tedges$to)
    res <- NULL
    i <- 0L
    if (is.null(key(tedges)) || key(tedges) != 'from')
        setkey(tedges, from)
    children <- tedges[from %in% from.node]
    while(nrow(children)) {
        children[, lvl := i]
        res <- rbind(res, children)
        children <- tedges[from %in% children$to]
        i <- i + 1L
    }
    res
}

get.parents <- function(tedges, from.node) {
    i <- 0L
    res <- vector("list", 1000)
    setkey(tedges, to)
    anc <- tedges[to %in% from.node]
    
    while(nrow(anc)) {
        anc[, lvl := i]
        i <- i + 1L
        res[[i]] <- anc
        anc <- tedges[to %in% anc$from]
    }
    rbindlist(res)
}



## * Convert subset of the edge data.table to phylo tree
edges2phylo <- function(tedges, idcol = 'virus_name', update.first = T) {

    e <- copy(tedges)
    if (update.first | !('to.tip' %in% names(tedges)))
        update.tree(e)

    rt <- get.root(e)
    
    tps <- e[to.tip == T, sort(unique(to))]
    ntips <- length(tps)
    nds <- c(rt, setdiff(sort(setdiff(unlist(e[, .(from, to)]), tps)), rt))
    nnodes <- length(nds)

    ## ** Re-name nodes and tips
    lkup <- data.table(id = c(tps, nds), is.tip = c(rep(T, length.out = ntips), rep(F, length.out = nnodes)))
    lkup[, newid := .I]
    setnames(e, c('from', 'to'), c('from.ori', 'to.ori'))

    e[lkup, from := i.newid, on = c('from.ori' = 'id')]
    e[lkup, to   := i.newid, on = c('to.ori'   = 'id')]
    setorder(e, -to.tip, to, from)
    
    m <- as.matrix(e[, .(from, to)])
    dimnames(m) <- NULL

    cols <- c('to', idcol)
    t <- list(edge        = m,
              edge.length = e$dist,
              Nnode       = nnodes,
              node.label  = NULL,
              tip.label   = e[to.tip == T, ..cols][order(to)][, get(idcol)]
              )
    class(t) <- 'phylo'
    attr(t, 'order') <- 'cladewise'

    list(phylo = t,
         edges = e)
}

## * Prepare data to be plotted - extract coordinates and make edges square if required
edges.plot.prep <- function(tedges, square.edges = T, id.col = 'vertex_id') {

    phy <- edges2phylo(tedges, idcol = id.col) # convert edges data.table back to phylo tree
    tt <- phy$phylo
    eds <- phy$edges

    ## checkValidPhylo(tt)

    ## ** Get coordinates without plotting
    p <- plot2(tt, type = 'phylogram', plot = F,
               show.tip.label = F, show.node.label = F,
               edge.color = 'black', tip.color = 'red', cex = 0,
               root.edge = F, use.edge.length = T,
               no.margin = T)

    ed <- data.table(p$coords$edge)
    xy <- data.table(x = p$coords$xx, y = p$coords$yy)
    xy[, id := .I]

    eds[xy, `:=`(from.x = i.x, from.y = i.y), on = c('from' = 'id')]
    eds[xy, `:=`(to.x = i.x, to.y = i.y), on = c('to' = 'id')]

    ## ** Make square segments
    if (square.edges) {
        e <- eds[from.x != to.x & from.y != to.y]
        ed <- e[, .(to.x = c(from.x, to.x), from.y = c(from.y, to.y), to.tip = c(F, first(to.tip)),
                    extra = c(T, F))
              , .(from, to, eid)]
        
        ed <- merge(ed, e[, c('eid', setdiff(names(e), names(ed))), with=F], by = 'eid')
        ed <- rbind(ed, eds[!(from.x != to.x & from.y != to.y)], fill = T)
    } else ed <- copy(eds)

    return(ed)
}



## * Assign common trait within clades

spread.clade.trait <- function(tedges, var, agg.var.name = 'children_common_trait') {

    if ('children_agg' %in% names(tedges))
        tedges[, children_agg := NULL]
    if (agg.var.name %in% names(tedges))
        tedges[, eval(agg.var.name) := NULL]
    tedges[, children_agg := get(var)]
    if ('curr_agg' %in% names(tedges))
        tedges[, curr_agg := NULL]
    
    ## aggval <- tedges[to.tip == T & !is.na(children_agg), mean(children_agg)]
    ## tedges[to.tip == T & is.na(children_agg), children_agg := aggval]
    
    mxnode <- tedges[, max(nthnode)]
    nod=mxnode-1
    for (nod in (mxnode-1):1L) {
        higher.lvl <- tedges[nthnode == nod+1L]
        higher.lvl[, curr_agg := fifelse(uniqueN(children_agg)==1, children_agg[1], 'multiple'), from]
        lower.lvl  <- tedges[nthnode == nod]
        ## lower.lvl[higher.lvl, children_agg := mean(i.children_agg, na.rm=T), on = c('to' = 'from')]
        lower.lvl[higher.lvl, children_agg := i.curr_agg, on = c('to' = 'from')]
        ## lower.lvl[higher.lvl, curr_agg := mean(i.children_agg, na.rm=T), on = c('to' = 'from')]
        tedges[lower.lvl, children_agg := i.children_agg, on = 'eid']
    }

    if (agg.var.name %in% names(tedges)) {
        tedges[, eval(agg.var.name) := NULL]
    }
    setnames(tedges, 'children_agg', agg.var.name)
    return(invisible(tedges))
}

spread.stat <- function(tedges, var, progress = T, agg.var.name = 'children_agg', stat.fun = mean) {

    tedges[, children_agg := get(var)]
    if ('curr_agg' %in% names(tedges))
        tedges[, curr_agg := NULL]
    
    aggval <- tedges[to.tip == T & !is.na(children_agg), mean(children_agg)]
    tedges[to.tip == T & is.na(children_agg), children_agg := aggval]
    
    mxnode <- tedges[, max(nthnode)]
    nod=mxnode-1
    for (nod in (mxnode-1):1L) {
        higher.lvl <- tedges[nthnode == nod+1L]
        higher.lvl[, curr_agg := stat.fun(children_agg, na.rm=T), from]
        lower.lvl  <- tedges[nthnode == nod]
        ## lower.lvl[higher.lvl, children_agg := mean(i.children_agg, na.rm=T), on = c('to' = 'from')]
        lower.lvl[higher.lvl, children_agg := i.curr_agg, on = c('to' = 'from')]
        ## lower.lvl[higher.lvl, curr_agg := mean(i.children_agg, na.rm=T), on = c('to' = 'from')]
        tedges[lower.lvl, children_agg := i.children_agg, on = 'eid']
    }

    setnames(tedges, 'children_agg', agg.var.name)

}




## points = NULL
## width = 55.5; height = 50; square.edges = T;
## edges.colour.by = 'children_trait'; points.colour.by = 'children_trait';
## palette.fun = NULL; z.var = NULL; z.trans.fun = I; max.z = 2e6;
## bgcol = '#EEEEEE'; tooltip = T;
## edge.vars = c('accession_id', 'vertex_id', 'children_trait');
## point.vars = c('accession_id', 'collection_date', 'continent',
##                'country', 'host', 'clade', 'lineage', 'children_trait');
## node.lab.glue = "ID: {accession_id}<br>Continent: {continent}<br>country: {country}<br>Date: {collection_date}";
## edge.lab.glue = "ID: {accession_id}<br>Vertex ID: {vertex_id}<br>{children_trait}"

tree2deck <- function(tedges, points = NULL, width = 55.5, height = 50, square.edges = T,
                      edges.colour.by = 'children_trait', points.colour.by = 'children_trait',
                      thickness.var = 'children_agg',
                      palette.fun = NULL, z.var = NULL, z.trans.fun = I, max.z = 2e6,
                      bgcol = '#EEEEEE', tooltip = T,
                      edge.vars = c('eid', 'continent_spread', 'country_spread'),
                      point.vars = c('eid', 'continent_spread', 'country_spread'),
                      node.lab.glue = '{eid}<br>{continent_spread}<br>{country_spread}',
                      edge.lab.glue = '{eid}<br>{continent_spread}<br>{country_spread}') {
    library(deckgl)

    in3D <- !is.null(z.var)
    if (in3D)
        tedges[, zval := get(z.var)]
    
    if (!('to.tip' %in% names(tedges)))
        tedges <- update.tree(tedges)

    e <- tedges

    if (is.null(points)) {
        t <- e[to.tip == T]
    } else t <- points

    if (!is.null(edges.colour.by) && !(edges.colour.by %in% names(e)))
        edges.colour.by <- NULL
    if (!is.null(points.colour.by) && !(points.colour.by %in% names(t)))
        points.colour.by <- NULL
    
    ## ** Colour
    if (!is.null(edges.colour.by)) {
        if (is.numeric(e[[edges.colour.by]])) {
            e[, colour := scales::cscale(get(edges.colour.by),
                                         scales::gradient_n_pal(colours = gplots::rich.colors(30)))]
        } else {
            if (e[!is.na(get(edges.colour.by)), all(grepl('^#', get(edges.colour.by)))]) {
                e[, colour := get(edges.colour.by)]
            } else {
                e[, colour := scales::dscale(factor(get(edges.colour.by)),
                                             pals::alphabet)]
            }
        }
    } else e[, colour := NA_character_]
    e[is.na(colour), colour := '#AAAAAA']

    if (!is.null(points.colour.by)) {
        if (points.colour.by %in% names(t)) {
            if (is.numeric(t[[points.colour.by]])) {
                t[, colour := scales::cscale(get(points.colour.by),
                                             scales::gradient_n_pal(colours = gplots::rich.colors(30)))]
            } else {
                if (t[!is.na(get(points.colour.by)), all(grepl('^#', get(points.colour.by)))]) {
                    t[, colour := get(points.colour.by)]
                } else {
                    t[, colour := scales::dscale(factor(get(points.colour.by)),
                                                 gplots::rich.colors)]
                }
            }
        } else t[, colour := points.colour.by] # if colour var not a field, assume it's a colour
    } else t[, colour := NA_character_]
    t[is.na(colour), colour := '#AAAAAA']
    
    maxx <- max(e$to.x)
    maxy <- max(e$to.y)

    t[, x := scales::rescale(to.x, c(0, width) , c(0, maxx))]
    t[, y := scales::rescale(to.y, c(0, height), c(0, maxy))]

    e[, start_x := scales::rescale(from.x, c(0, width), c(0, maxx))]
    e[, start_y := scales::rescale(from.y, c(0, height), c(0, maxy))]
    e[, end_x := scales::rescale(to.x, c(0, width), c(0, maxx))]
    e[, end_y := scales::rescale(to.y, c(0, height), c(0, maxy))]
    if (!is.null(thickness.var) && thickness.var %in% names(e)) {
        e[, linewidth := scales::rescale(sqrt(get(thickness.var)), c(1, 20))]
    } else e[, linewidth := 1]
        
    if (in3D) {
        zrange <- e[, range(zval, na.rm=T)]
        t[, z       := scales::rescale(z.trans.fun(zval)    , c(0, max.z), z.trans.fun(zrange))]
        e[, start_z := scales::rescale(z.trans.fun(curr_agg), c(0, max.z), z.trans.fun(zrange))]
        e[, end_z   := scales::rescale(z.trans.fun(zval)    , c(0, max.z), z.trans.fun(zrange))]
    } else {
        t[, z := NA]
        e[, c('start_z', 'end_z') := NA]
    }

    vars <- c('x', 'y', 'z', 'colour', point.vars)
    pp <- t[, ..vars]
    vars <- c('start_x', 'start_y', 'start_z', 'end_x', 'end_y', 'end_z', 'colour', 'linewidth', edge.vars)
    ll <- e[, ..vars]

    root <- setdiff(tedges$from, tedges$to)
    rootpt <- e[from == root][1, .(start_x, start_y, start_z, end_x, end_y, end_z, eid)]

    pp[, label := glue::glue(node.lab.glue, envir = .SD)]
    ll[, label := as.character(glue::glue(edge.lab.glue, envir = .SD))]

    
    leg <- tedges[!is.na(colour), .N, c(edges.colour.by, 'colour')][order(get(edges.colour.by))]
    setnames(leg, edges.colour.by, 'val')

    if (in3D) {

        if (tooltip) {

            proplines <- list(
                getSourcePosition = ~ start_x + start_y + start_z,
                getTargetPosition = ~ end_x + end_y + end_z,
                getTooltip = JS("object =>`${object.label}`"),
                getWidth = 1,
                pickable = T,
                opacity = 0.5,
                visible = T,
                getColor = get_color_to_rgb_array('colour')
            )
            
            proppoints <- list(
                getPosition = ~ x + y + z,
                getColor = get_color_to_rgb_array('colour'),
                getFillColor = get_color_to_rgb_array('colour'),
                getRadius = 1000,
                getTooltip = JS("object =>`${object.label}`"),
                stroked = T,
                pointSize = 2,
                radiusScale = 8,
                radiusMinPixels = 1.5,
                radiusMaxPixels = 5,
                opacity = 0.8
            )

            proproot <- list(
                getPosition = ~ start_x + start_y + start_z,
                getColor = '#000000',
                getFillColor = '#FFFFFF',
                getRadius = 1000,
                getTooltip = "Tree root<br>Epi-id: {{eid}}",
                stroked = T,
                radiusScale = 8,
                radiusMinPixels = 5,
                radiusMaxPixels = 15,
                opacity = 1
            )
            

            deck <- deckgl(width='100vw', height='100vh', latitude = 25, longitude = 25, zoom = 3,
                           pitch = fifelse(in3D, 60, 0), maxPitch = 89.9,
                           style = list(background = bgcol)) %>%
                add_line_layer(data = ll[, .(start_x, start_y, start_z, end_x, end_y, end_z, colour, label)],
                               properties = proplines) %>%
                add_scatterplot_layer(data = pp[, .(x, y, z, colour, label)], properties = proppoints) %>%
                add_scatterplot_layer(data = rootpt[, .(start_x, start_y, start_z, eid)], properties = proproot) %>%
                add_legend(
                    colors = leg$colour,
                    labels = leg$val,
                    title = '',
                    pos = 'top-left'
                )
            
        } else {
            
            proppoints <- list(
                getPosition = ~ x + y + z,
                getColor = get_color_to_rgb_array('colour'),
                getFillColor = get_color_to_rgb_array('colour'),
                getRadius = 1000,
                stroked = T,
                pointSize = 2,
                radiusScale = 8,
                radiusMinPixels = 1.5,
                radiusMaxPixels = 5,
                opacity = 0.8
            )
            
            proplines <- list(
                getSourcePosition = ~ start_x + start_y + start_z,
                getTargetPosition = ~ end_x + end_y + end_z,
                getWidth = 1,
                pickable = T,
                opacity = 0.5,
                visible = T,
                getColor = get_color_to_rgb_array('colour')
            )
 
            proproot <- list(
                getPosition = ~ start_x + start_y + start_z,
                getColor = '#000000',
                getFillColor = '#FFFFFF',
                getRadius = 1000,
                stroked = T,
                radiusScale = 8,
                radiusMinPixels = 5,
                radiusMaxPixels = 15,
                opacity = 1
            )
           
            deck <- deckgl(width='100vw', height='100vh', latitude = 25, longitude = 25, zoom = 3,
                           pitch = fifelse(in3D, 60, 0), maxPitch = 89.9,
                           style = list(background = bgcol)) %>%
                add_line_layer(data = ll[, .(start_x, start_y, start_z, end_x, end_y, end_z, colour)],
                               properties = proplines) %>%
                add_scatterplot_layer(data = pp[, .(x, y, z, colour)], properties = proppoints) %>%
                add_scatterplot_layer(data = rootpt[, .(start_x, start_y, start_z)], properties = proproot) %>%
                add_legend(
                    colors = leg$colour,
                    labels = leg$val,
                    title = '',
                    pos = 'top-left'
                )

        }
        
    } else {

        if (tooltip) {
            
            proplines <- list(
                getSourcePosition = ~ start_x + start_y,
                getTargetPosition = ~ end_x + end_y,
                getTooltip = JS("object =>`${object.label}`"),
                getWidth = ~ linewidth,
                widthScale = 1,
                pickable = T,
                opacity = 0.8,
                visible = T,
                getColor = get_color_to_rgb_array('colour')
            )

            proppoints <- list(
                getPosition = ~ x + y,
                getColor = get_color_to_rgb_array('colour'),
                getFillColor = get_color_to_rgb_array('colour'),
                getRadius = 1000,
                getTooltip = JS("object =>`${object.label}`"),
                stroked = T,
                radiusScale = 8,
                radiusMinPixels = 1.5,
                radiusMaxPixels = 5,
                opacity = 0.8
            )

            proproot <- list(
                getPosition = ~ start_x + start_y,
                getColor = '#000000',
                getFillColor = '#FFFFFF',
                getRadius = 1000,
                getTooltip = "Tree root<br>Epi-id: {{eid}}",
                stroked = T,
                radiusScale = 8,
                radiusMinPixels = 5,
                radiusMaxPixels = 15,
                opacity = 1
            )

            deck <- deckgl(width='100vw', height='100vh', latitude = 25, longitude = 25, zoom = 3,
                           pitch = fifelse(in3D, 60, 0), maxPitch = 89.9,
                           style = list(background = bgcol)) %>%
                add_line_layer(data = ll[, .(start_x, start_y, end_x, end_y, colour, label, linewidth)],
                               properties = proplines) %>%
                add_scatterplot_layer(data = pp[, .(x, y, colour, label)], properties = proppoints) %>%
                add_scatterplot_layer(data = rootpt[, .(start_x, start_y, eid)], properties = proproot) %>%
                add_legend(
                    colors = leg$colour,
                    labels = leg$val,
                    title = '',
                    pos = 'top-left'
                )
            
        } else {

            proppoints <- list(
                getPosition = ~ x + y,
                getColor = get_color_to_rgb_array('colour'),
                getFillColor = get_color_to_rgb_array('colour'),
                getRadius = 1000,
                stroked = T,
                radiusScale = 8,
                radiusMinPixels = 1.5,
                radiusMaxPixels = 5,
                opacity = 0.8
            )

            proproot <- list(
                getPosition = ~ start_x + start_y,
                getColor = '#000000',
                getFillColor = '#FFFFFF',
                getRadius = 1000,
                stroked = T,
                radiusScale = 8,
                radiusMinPixels = 5,
                radiusMaxPixels = 15,
                opacity = 1
            )

            proplines <- list(
                getSourcePosition = ~ start_x + start_y,
                getTargetPosition = ~ end_x + end_y,
                getWidth = 1,
                pickable = T,
                opacity = 0.8,
                visible = T,
                getColor = get_color_to_rgb_array('colour')
            )

            deck <- deckgl(width='100vw', height='100vh', latitude = 25, longitude = 25, zoom = 3,
                           pitch = fifelse(in3D, 60, 0), maxPitch = 89.9,
                           style = list(background = bgcol)) %>%
                add_line_layer(data = ll[, .(start_x, start_y, end_x, end_y, colour)],
                               properties = proplines) %>%
                add_scatterplot_layer(data = pp[, .(x, y, colour)], properties = proppoints) %>%
                add_scatterplot_layer(data = rootpt[, .(start_x, start_y)], properties = proproot) %>%
                add_legend(
                    colors = leg$colour,
                    labels = leg$val,
                    title = '',
                    pos = 'top-left'
                )

        }
        
    }
    
    return(deck)
}

tree.from.edge <- function(tedges, sel.eid=123309) {
    from.node <- tedges[eid == sel.eid, to]
    pars <- get.parents(tedges, from.node)
    childs <- get.children(tedges, from.node)
    rbind(pars, childs)
}

tree.from.attribute <- function(tedges, attr.var = 'country', attr.val = 'Australia') {
    te <- tedges[get(attr.var) == attr.val]
    tetips <- te[to.tip == T]
    parents <- get.parents(tedges, tetips$to)
    parents <- unique(parents[, -'lvl'])
    parents
}


upper1st <- function (x, prelower = T) {
    if (is.factor(x)) {
        x0 <- levels(x)
    } else x0 <- as.character(x)
    if (prelower) x0 <- tolower(x0)
    nc <- nchar(x0)
    nc[is.na(nc)] <- 0
    x0[nc > 1] <- sprintf("%s%s", toupper(substr(x0[nc > 1], 1, 1)),
                          substr(x0[nc > 1], 2, nchar(x0[nc > 1])))
    x0[nc == 1] <- toupper(x0[nc == 1])
    if (is.factor(x)) {
        levels(x) <- x0
    } else x <- x0
    return(x)
}

hier.pal <- function(category, subcategory, spread.within = 0.3,
                     chroma = 110, luminance = 70, alpha = 1) {

    cols0 <- data.table(id1 = category, id2 = subcategory)
    cols0[, i := .I]
    setkey(cols0, id1, id2)

    cols <- cols0[, .N, .(id1, id2)]

    ncats <- uniqueN(cols$id1)
    steps <- seq(0, 360, length.out = ncats + 1)
    diff <- steps[2]-steps[1]
    steps <- steps + diff / 2
    
    steps <- head(steps, ncats)
    names(steps) <- unique(cols$id1)
    cols[, step := steps[id1]]

    spread <- diff * spread.within / 2
    cols[, offset := seq(-spread, spread, length.out = .N), id1]
    cols[, hue := step + offset]
    
    cols[, c := chroma + offset]
    cols[, l := luminance + offset]

    cols[, col := hcl(h = hue, c = c, l = l, alpha = alpha)]

    setorder(cols0, i)
    return(cols[cols0, col, on = c('id1', 'id2')])
}
