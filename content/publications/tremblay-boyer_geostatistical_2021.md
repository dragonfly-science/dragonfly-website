---
pdf: tremblay-boyer_geostatistical_2021.pdf
tags: laura, philipp, katrin, fisheries, dragonfly, report
---
Fishery surveys are aimed at collecting information about target species, such as the
population abundance, density, and size structure. The analyses of these data are
dependent on the sampling design and type and amount of data collected, with the assessments
generally focused on providing robust and reliable population estimates. For longer-term
monitoring series, survey data also allow the assessment of population trends over
time when the data collection methods have been consistent between surveys.

Across northern North Island, regular (usually annual) surveys of intertidal bivalves
(cockle or littleneck clam, tuangi *Austrovenus stuchburyi*
 and pipi *Paphies australis*) were initiated in the early 1990s, prompted by concerns
 about the potential impact of recreational and customary fisheries.
 The surveys are commissioned by Fisheries New Zealand (and its predecessors) and
 encompass a diverse range of coastal habitats in the wider Auckland, Northland,
 Waikato and Bay of Plenty regions. Across the northern region, the surveys focus
 on twelve sites each year, with the sampling at each site surveying bivalve beds
 that are considered to be targeted in non-commercial fisheries.

 From the survey data, the population abundance at each site is derived from a sampling-based
 estimator by extrapolating local density (individuals per square metre),
calculated from the number of individuals per sampling unit to the stratum size.
Nevertheless, recent data have documented the presence of high-density cockle
patches that seemed to shift unpredictably between surveys, resulting in population
estimates with relatively high uncertainty. This high uncertainty suggested that
fixed stratification and the survey-based estimation may not be the most appropriate
approach for providing population estimates. For this reason, the current study
explored a model-based geostatistical approach, which may be more suitable for
inference of abundance than survey-based estimators at sites with high variability.
Model-based geostatistical estimators interpolate between observations to generate
site-wide predictions, also accounting for the correlation between observations as
the distance increases between them. This feature may result in more accurate site-wide
estimates of abundance than the sampling-based estimator, which implicitly assumes
that the un-sampled areas share the same density as the nearest observation.

Geostatistical models have been used for the northern bivalve surveys since 2015–16 to
design the optimal shape and location of strata at each site prior to the field sampling.
The current study was aimed at extending this approach, by deriving model-based
geostatistical estimates for all 12 sites of the 2019–20 survey, and comparing them
with survey-based estimates.  The model exploration was focused on providing an understanding
of situations when the model-based estimators may be more suitable than sampling-based estimators,
including the precision of estimates.  The model exploration was limited to cockle populations,
because pipi populations may extend into subtidal areas that are not accessible during
the intertidal field sampling. In addition to comparing estimates from the two different
approaches, two operational components necessary to conduct geostatistical models were explored:
first, the design of the triangulated "mesh" that
is required as part of the Stochastic Partial Differential Equations (SPDE) approach
that was used for the geostatistical modelling, and for which a spatial
effect is estimated for each vertex; and second,
the use of performance metrics to inform model selection. For each site,
models were run using the most recent survey data, and also with the addition of a
temporal correlation structure, allowing the inclusion of multiple years of survey data.

Owing to the diversity in the spatial configuration of survey sites, a set of general
rules was trialled to define a mesh design framework that could be applied across sampling locations.
These rules focused on the spatial resolution of the mesh as a function of the 5th quantile of
the distribution of the smallest distance between samples, how tightly the shape of the inner
mesh area should be constrained  by the overall sampling strata shape, and how much buffer
around each stratum should be included as part of the inner mesh. No universal framework was
ascertained for the mesh design that resulted in the highest-ranked model for each site. Instead,
model performance for some sites appeared to be robust to mesh configuration; most mesh
configurations resulted in realistic predictions of site-wide abundance with coefficient of
variation (CV) values below or close to the 20% threshold of the target CV for the sampling-based
estimates. For other sites, only specific mesh configurations achieved a similar result,
with the best-performing mesh configuration varying amongst those sites.

Because there is no "true" measure of site-wide abundance, the estimates from the
two different approaches were compared using precision only.
 This comparison showed that the highest-ranked geostatistical
model selected for each site resulted in more precise estimates of population abundance
for most sites. Nevertheless, the results could be sensitive to model configuration, and
some models appeared to predict implausible results. For this reason, a set of
criteria was defined for model selection, which accounted for model
performance under traditional metrics, and discarded models that failed to meet
specific standards for predictions and diagnostics. In general, for the same mesh
configuration, the spatio-temporal model using all surveyed years tended to result
in more stable square-metre and site-wide predictions, despite increased model complexity.

For most site-mesh combinations, the three performance metrics included in this
study did not always select against models making unrealistic predictions at the fine-scale level.
Nevertheless, once unrealistic models were omitted, all three performance metrics
tended to select the same highest-ranked model, which was usually the model with the closest fit
 to the observations. Mesh complexity did not appear to be penalised by model selection,
 and the selected models often had finer mesh configurations.

In summary, the current study found that although geostatistical models can
provide population estimates with greater precision than sampling-based estimators,
results can be sensitive to model configuration. Model selection needs to account
for factors beyond performance metrics, and for site configuration. In general,
it is recommended that spatio-temporal models are favoured as they were more robust
to mesh configuration, and yielded more precise population estimates for most sites.
Single-year models should still be used for sites with high inter-annual variability
in cockle bed locations.
