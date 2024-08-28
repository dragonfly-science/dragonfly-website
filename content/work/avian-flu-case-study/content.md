---
title: Rapid identification of avian flu viruses
short-title: Avian flu
banner-image: /work/avian-flu-case-study/avian-flu-header.jpg
testimonial:
  - testimonials/avian-flu-testimonial/content.md
logo: /work/avian-flu-case-study/MPI-logo.png
summary: 
tags: systems
description: We are building the systems that will help New Zealand respond rapidly to an avian flu outbreak. 
CTADescriptor: some text
CTAButton: read more
sortorder: 1
---

Understanding Avian Influenza variants in New Zealand: a collaborative project between 
Dragonfly Data Science and the Ministry for Primary Industries

<!--more-->

### Avian flu

High pathogenicity avian influenza (HPAI)—also known as avian flu–is a
viral disease that is affecting domestic and wild birds around the world. 

New Zealand remains free from high pathogenicity avian flu, while low
pathogenicity avian influenza is endemic within the country. However, the full
distribution and genetic structure of the variants present in New Zealand
remain largely unknown.

To address this knowledge gap, a new project has been launched by the Ministry
for Primary Industries (MPI) and Dragonfly, aimed at sequencing 300 virus
isolates collected by MPI since the 1970s. 

### Building a database of New Zealand variants

This project uses modern genomic sequencing methods to map the genetic
landscape of virus variants in New Zealand, providing crucial data on the
number of variants, their locations, and their evolution over time.

Dragonfly has been engaged to build a comprehensive searchable database for
this project. We are also assisting in creating an automated classification
system to quickly identify subtypes from new samples. This system will enhance
our understanding of the variants endemic to New Zealand and allow for rapid
identification and response in the event of an incursion by a high pathogenic
variant.

The availability of this detailed database will be invaluable for
distinguishing between an imported high pathogenic strain and one that may
arise from mutation or recombination of existing low pathogenic variants. 


### Tools for rapid identification

Given that new pathogenic variants can potentially infect new hosts, including
mammals and humans, this project is particularly timely. For instance, a
current outbreak in the USA involves a variant (H5N1) infecting cattle.

By employing modern genomics, this project aims to reduce reaction times
significantly, streamlining sample processing and data analysis. 

Preliminary tests indicate that avian influenza subtypes can be identified
within 48 hours, a capability that mirrors similar approaches successfully
implemented for COVID-19 samples by ESR.

### The technology

To enable rapid analysis, 
we wrote a python script to process the data as it streams from the Nanopore sequencer. 
By using information theory measures, we are able to compare the
distribution of k-mers from the raw reads with the distribution from
reference sequences. This allows us to identify the 
virus subtype as soon as enough of the sample has been processed.
 Because the script has a simple text interface, it is
able to run on remote computures, such as on the New Zealand scientific
computing infrastructure (NESI). This will let us rapidly subtype large databases
of flu viruses. 

## Project team

[Brett Calcott](/people/calcott-brett.html)
