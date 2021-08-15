---
title: Antipodean albatross integrated population model
short-title: Antipodean albatross integrated population model
summary: A model and simulation tool predict the effect of different management
 strategies on this Nationally Critical species.
tags: stats, policy
banner-image: /work/Antipodean-albatross-case-study/banner.jpg
testimonial:
  - testimonials/Antipodean-albatross/content.md
logo: /work/Antipodean-albatross-case-study/DOC-logo.png
description: >
  We built a model and simulation tool to predict the effect of different management
   strategies on this Nationally Critical species.
project-link: https://docnewzealand.shinyapps.io/Antipodean_albatross_IPM/
project-link-text: View tool
CTADescriptor: some text
CTAButton: read more
---

Action to halt the estimated annual 5 percent decline of the Antipodean albatross
population is essential. The model and app we created allow stakeholders to
explore the effects of different threats and management strategies. This is
intended to help guide decisions to secure the future of the species.  

<!--more-->

### Albatross flying into trouble

Antipodean albatross fly across the world but only breed on the isolated Antipodes
 Island, 750 km southeast of New Zealand. Their population has declined by two
 thirds in the last 15 years from about 16,000 to 6,000 breeding birds. Each
 season birds leave the island but some, especially females, fail to return.

The major threat to the population is thought to be accidental capture by longline
fishing vessels outside New Zealand waters. Bycatch within New Zealand waters
and climate change are additional threats.

### A simulation tool to guide decision-making

understand the future trajectory of the Antipodean albatross population, as well
 as the effect of different measures that could be taken to reverse the decline.

Being able to model the effects of different management strategies (like reducing
   bycatch) was seen as a powerful tool to include stakeholders in the
   decision-making process.

### Developing an integrated population model  

The model uses Bayesian statistics to estimate the main demographic parameters
that are driving the population dynamics. It takes into account the detectability
of individual birds, annual variations of survival rates and breeding success,
and movements in and out of the study area.

The software *Stan* was used to fit the model and produce the parameters and the
associated uncertainty. The parameters were then used to simulate the fate of
the population. The model indicates with reasonable confidence that the population
is declining at about 5 percent per year.

### Good data collection and preparation

Data for the model was collected by DOC scientists Kath Walker and Graeme Elliott.
They have ensured Antipodes Island was visited for 4-6 weeks almost every summer
for the last 27 years. This modelling work would not have been possible without
their dedication and support.

For the first few years, Kath and Graeme counted nests on the whole island. After
this, they focussed most of their work on birds in one more accessible corner of the island
  to increase the accuracy of the data. They noted when banded birds left, returned, bred or
  disappeared using capture-recapture methods. This data was then extrapolated
  within the integrated population model to represent the whole population.

Kath and Graeme were involved throughout this project, especially in the start-up
 phase when the data was being prepared. The final population model mirrors the
 serious decline they have seen in the number of birds since 2006.

### Simulation tool is online and easy to use

DOC chose to make the tool open access using a Shiny app so people can see what
needs to happen to stabilise the population and prevent further decline. Changing
parameters in the app allows people to see for themselves what is needed – and
what happens if the death of 100 birds can be prevented, for example.

The accessibility of the app also supports transparency and agreement between
stakeholders about which actions should be prioritised.  

### Complexity and uncertainty

Unlike models where data for a whole population is available, this model is
based on data from a portion of the total albatross population. This adds
uncertainty because if a bird is not seen one year, it may be dead or simply
living in another part of the colony. (Fortunately this is rare because these
albatross have strong nest-site fidelity.) Statistical methods were used to
separate these possibilities.

The model also takes account of the life stages of the birds, from chick to juvenile,
 pre-breeder and adult and the different demographic parameters for each stage.

### Model indicates further population decline

This model confirms previous work, but is much more robust. Despite being able
to account for the possibility that missing birds are living elsewhere, the
population trajectory for the birds remains dire.

The results also indicate that many threats are working together to cause the
serious population decline. This suggests that a more holistic approach to
conservation at sea is required to safeguard the future of the species.

### More information

[Read the final project report and access the simulation tool](https://www.doc.govt.nz/our-work/conservation-services-programme/csp-reports/202021/integrated-population-model-of-antipodean-albatross-for-simulating-management-scenarios/).
[Watch a video about Kath and Graeme’s data-collection work](https://www.youtube.com/watch?v=ZSLloHR7Izo).
[Read a Beehive media release about the work](https://www.beehive.govt.nz/release/government-taking-action-protect-albatross).
