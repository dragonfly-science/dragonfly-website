---
pdf: thompson_querying_2015.pdf
tags: finlay, dragonfly, presentation
---

A presentation to the Wellington PostgreSQL Users Group, about the use of
PostgreSQL for storying Bayesian model output. Samples from the posterior
distributions are stored in arrays, allowing for rapid aggregation of the
results. In our case, models of protected species bycatch have 4000 samples for
each of 1.5 million fishing events. These may be aggregated by area, or by
fishing method, to give estimates of bycatch with the associated uncertainty.
This database of model output is used to generate the graphs and tables seen on
the [Protected Species Bycatch website](http://data.dragonfly.co.nz/psc).

