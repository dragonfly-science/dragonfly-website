---
title: Inferring animal dispersal from geochemical proxies: open source R package online
---
To pinpoint the natal origins of settling fish in Cook Strait, near
Wellington, Philipp Neubauer measured geochemical signatures in fish
otoliths (ear bones). A new Bayesian modelling approach allowed him to
estimate dispersal of larval fish among local populations in the
region. These models are now available in an open-source package for
the statistical computing environment R.

<!--more-->

Studying populations of reef fish in Cook Strait during his PhD was a
challenge for Philipp Neubauer in more ways than one. Not only was he
confronted by fierce southerly swells while diving for fish larvae, he
also had to find ways to analyse the complex data that was generated
from his collections.

To pinpoint the natal origins of settling fish in Cook Strait, near
Wellington, he measured geochemical signatures in fish otoliths (ear
stones). A new Bayesian modelling approach allowed him to estimate
dispersal of larval fish among local populations in the region. ![Fish
hatchling otoliths in the larval head (left and centre close up) and
extracted (right). The diameter of the otolith is ~ 25
microns.](../posts/2013-09-11-inferring-animal-dispersal/Triplehead.png)

He has recently made these models publicly available as an open-source
package for the statistical computing environment R via the open
source repository [GitHub](https://github.com/Philipp-Neubauer/PopR).
The package uses R for data grooming and analysis of outputs, the
computationally expensive MCMC calculations are performed using the
new open source technical computing language
[julia](http://julialang.org/), which is called from within R.

“I wanted to make the software available so that other people can use
it. That way it will get trialed in different environments – the bugs
will be found out, then hopefully fixed, and people will apply it to
new problems. This sort of collaboration is a real strength of
open-source software. The combination of an R front end and a julia
back end will hopefully lead to more straightforward uptake by
ecologsits, who are more familiar with R, while allowing efficient
computing and extensions to new applications in the underlying julia
back end.”

He hopes to include models for genetic data as well as a combined
model for geochemical and genetic data soon. "Such an extension would
really broaden the applicability of the methods, and will allow for a
direct comparison of results from genetic and geo-chemical studies."

Dragonfly share the same approach to using and producing open-source
software; not only to solve data problems for their clients but also
to progress science more broadly.
