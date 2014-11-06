---
title: Generating enhanced SVG from R
author: risto 
teaser: |
    More about SVG
...


I recently wrote a post about not redrawing using d3.js, rather (I believe) it
makes more sense create web compatible output (SVG) directly from an analysis
environment and add the minimal javascript needed in create an interative 
experience rather than re-implementing entire plotting/rendering libraries
clientside.

Hello

In this post I will walk through a simple ggplot2 example using the built-in
diamonds dataset. The ggplot2 documentation has an example of a multi-facet bar
chart of the clarity of diamonds. Let's create an interactive version of the
same plot.

The steps involved are:

- Loop over the facets of the data and create the ggplot plot for each facets.
  Although it is not stricly necessary we often render out a png version of
  each facet as it can be used later to support older browsers.
- Once each facet has been rendered store the data that is changing - in the 
  case of a bar chart with a fixed y-axis this is only the height of the bars
- Render a _primary_ image and export as SVG.
- Save the facet changes as JSON within the SVG
- Add a script to the SVG to enable changes between the facet views.

The original faceted bar chart is created like this:

    library(ggplot2)
    ggplot(diamonds, aes(clarity)) + geom_bar() +
        facet_wrap(~ cut)

Unfortunately the creating the interactive version is not quite so elegant. We start
by defining a function to render our facets.

    draw_plot <- function(data) {
        g <- ggplot(data, aes(clarity)) + geom_bar()
        return(g)
    }

And a function to extract 
