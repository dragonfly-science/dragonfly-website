---
title: Rapid identification of avian flu viruses
---

Understanding avian influenza variants in New Zealand: a collaborative project between 
Dragonfly Data Science and the Ministry for Primary Industries

<!--more-->

### Avian flu

High pathogenicity avian influenza (HPAI)—also known as avian flu–is a
viral disease that is affecting domestic and wild birds around the world. 

New Zealand remains free from high pathogenicity avian flu, while its 
low-pathogenic counterpart is endemic within the country. However, the full
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
identification and response in the event of an incursion by a highly-pathogenic
variant.

The availability of this detailed database will be invaluable for
distinguishing between an imported highly-pathogenic strain and one that may
arise from mutation or recombination of existing low-pathogenic variants. 


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

MPI uses a [Nanopore](https://nanoporetech.com/about/) sequencer, 
which processes multiple prepared virus samples at the same time.
Over several hours, the sequencing programme streams reads of DNA strands 
from the samples into a folder on an attached computer.
These reads can ultimately be assembled into entire virus genomes.
But this assembly process is complex and time-consuming.
Our challenge was to recognise the particular subtype of virus *in real time*,
quickly alerting us to any highly-pathogenic variants.

We decided to use a k-mer based approach.
A k-mer is a short, fixed-size (say 10-30 base pairs) section of overlapping DNA.
Any section of DNA can be converted into a set of k-mers,
and counting the number of unique k-mers in all the incoming reads produces a k-mer distribution.
By comparing it to k-mer distributions from viruses that have 
already been recognised,
we could quickly establish which virus the reads most resembled.

We wrote text user interface (TUI) that screens the incoming files and 
updates the results in only a few seconds.
The programme can be run on the sequencing computer via a remote login,
and also works on the New Zealand scientific
computing infrastructure (NESI), where MPI stores and processes many of the results.
This approach will let us rapidly subtype large databases
of flu viruses. 

The programme is written in Python, and makes use of a number of 
open-source packages to produce the user interface and process the k-mers.

### Read more

[Our work with GISAID on COVID-19](/news/2022-07-01-audacity-instant.html), 
