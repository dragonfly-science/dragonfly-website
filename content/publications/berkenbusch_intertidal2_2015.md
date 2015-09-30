---
pdf: FAR_2015_59_2933_AKI 2014-01.pdf
tags: katrin, philipp, fisheries, dragonfly, benthic, report, shellfish
---
In New Zealand's sheltered coastal environments, bivalve species targeted in
recreational and customary fisheries include cockles (tuangi/tuaki, or
littleneck clam, \emph{Austrovenus stuchburyi})  and pipi (\emph{Paphies
australis}), which both inhabit sedimentary habitats throughout the country. In
the northern North Island region, cockles and pipi are the principal fisheries
species in sheltered environments of beaches, harbours, and estuaries, where
some populations are under considerable pressure from these non-commercial
fishing activities. To monitor the northern cockle and pipi populations, the
Ministry for Primary Industries (MPI) commissions regular population
assessments in northern North Island, with survey sites distributed across the
wider Auckland region, Northland, Waikato, and Bay of Plenty. 

The present study documents the most recent bivalve survey in the northern
North Island region, conducted in \mbox{2014--15}. The sites included in this
survey were (in alphabetical order) Aotea Harbour, Eastern Beach, Kawakawa Bay
(West), Mangawhai Harbour, Mill Bay, Ngunguru Estuary, Otumoetai (Tauranga
Harbour), Raglan Harbour, Ruakaka Estuary, Te Haumi Beach, Whangamata Harbour,
and Whangapoua Harbour.   At each site, the population survey focused on areas
targeted by non-commercial fisheries to determine the abundance and population
densities of cockles and pipi.  The survey also involved the collection of
sediment data (grain size and organic content) to provide broad-scale baseline
information about some of the habitat characteristics that influence bivalve
populations.    


All of the \mbox{2014--15}  survey sites contained cockle populations.  Cockle population sizes and densities varied across sites, with total abundance estimates  ranging from the smallest population of \Sexpr{subset(summary_table_cockle,beach_long == 'Mill Bay',select = 'Cockle_total')} million (CV: \Sexpr{subset(summary_table_cockle,beach_long == 'Mill Bay',select = 'Cockle_cv')}\%) cockles at Mill Bay to the largest population of \Sexpr{subset(summary_table_cockle,beach_long == 'Raglan Harbour',select = 'Cockle_total')} million (CV: \Sexpr{subset(summary_table_cockle,beach_long == 'Raglan Harbour',select = 'Cockle_cv')}\%) individuals at Raglan Harbour. Whangamata Harbour and Ngunguru Estuary also supported large cockle populations, with an estimated \Sexpr{subset(summary_table_cockle,beach_long == 'Whangamata Harbour',select = 'Cockle_total')} million (CV: \Sexpr{subset(summary_table_cockle,beach_long == 'Whangamata Harbour',select = 'Cockle_cv')}\%)  and \Sexpr{subset(summary_table_cockle,beach_long == 'Ngunguru Estuary',select = 'Cockle_total')} million (CV: \Sexpr{subset(summary_table_cockle,beach_long == 'Ngunguru Estuary',select = 'Cockle_cv')}\%) cockles, respectively.  Population densities were also variable, with relatively high density estimates at three sites, Ngunguru Estuary, Raglan Harbour, and Whangamata Harbour, ranging from  \Sexpr{subset(summary_table_cockle,beach_long == 'Whangamata Harbour',select = 'Cockle_dens')} cockles 
per m$^{2}$ at Whangamata Harbour to \Sexpr{subset(summary_table_cockle,beach_long == 'Ngunguru Estuary',select = 'Cockle_dens')} cockles per m$^{2}$ at Ngunguru Estuary.  At the remaining sites, cockle densities were considerably lower, with the next highest estimate of \Sexpr{subset(summary_table_cockle,beach_long == 'Ruakaka Estuary',select = 'Cockle_dens')} cockles per m$^{2}$ (CV: \Sexpr{subset(summary_table_cockle,beach_long == 'Ruakaka Estuary',select = 'Cockle_cv')}\%) at Ruakaka Estuary.  The lowest population density was  \Sexpr{subset(summary_table_cockle,beach_long == 'Eastern Beach',select = 'Cockle_dens')} cockles per m$^{2}$ (CV: \Sexpr{subset(summary_table_cockle,beach_long == 'Eastern Beach',select = 'Cockle_cv')}\%) at Eastern Beach.  

Most cockle populations were dominated by small and medium-sized cockles, with relatively low numbers and densities of large individuals ($\ge$30~mm shell length).  
%needs more on the large ones
Furthermore, time-series comparisons across surveys (starting in \mbox{1999--2000}) documented a general decrease in the population of large cockles, with only Eastern Beach reflecting a notable increase in this size class in \mbox{2014--15}.  In contrast, recruits ($\le$15~mm shell length) were abundant at the majority of sites, where they constituted a considerable proportion of the population (up to %\Sexpr{ subset(LF_tab,year == '2014--15',select = 'recruits')}\% 
53.82\% at Ruakaka Estuary).
%need to refer to Ruakaka table

Pipi populations were present at 11 (of the total 12) sites in the \mbox{2014--15} survey, excluding Aotea Harbour, where only one individual was sampled.   Most of the pipi populations were small, and abundances were only relatively high at three sites, Te Haumi Beach, Ruakaka Estuary, and Otumoetai (Tauranga Harbour), where pipi numbers ranged between an estimated total of  \Sexpr{subset(summary_table_pipi,beach_long == 'Te Haumi Beach',select = 'Pipi_total')} million (CV: \Sexpr{subset(summary_table_pipi,beach_long == 'Te Haumi Beach',select = 'Pipi_cv')}\%; Te Haumi Beach) and \Sexpr{subset(summary_table_pipi,beach_long == 'Otumoetai',select = 'Pipi_total')} million (CV: \Sexpr{subset(summary_table_pipi,beach_long == 'Otumoetai',select = 'Pipi_cv')}\%; Otumoetai) individuals. The corresponding population densities at these sites were \Sexpr{subset(summary_table_pipi,beach_long == 'Te Haumi Beach',select = 'Pipi_dens')} pipi to \Sexpr{subset(summary_table_pipi,beach_long == 'Otumoetai',select = 'Pipi_dens')} pipi  m$^{2}$ (at Te Haumi Beach and Otumoetai, respectively), compared with considerably lower densities at the remaining sites, including a maximum density of \Sexpr{subset(summary_table_pipi,beach_long == 'Mill Bay',select = 'Pipi_dens')} pipi per m$^{2}$ (at Mill Bay). 

There was a general scarcity of large pipi ($\ge$50~mm shell length) in the \mbox{2014--15} populations, and this size class was absent at five of the sites surveyed. 
% absent at Eastern Beach, Kawakawa Bay (West), Mill Bay, and Ngunguru Estuary.    
%Only two sites supported comparatively high numbers of large pipi, i.e.,  at population sizes exceeding 0.5 million individuals,  with \Sexpr{subset(summary_table_pipi,beach_long == 'Whangamata Harbour',select = 'large_Pipi_total')} million (CV: \Sexpr{subset(summary_table_pipi,beach_long == 'Whangamata Harbour',select = 'large_Pipi_cv')}\%) large pipi at Whangamata Harbour and \Sexpr{subset(summary_table_pipi,beach_long == 'Te Haumi Beach',select = 'large_Pipi_total')} million (CV: \Sexpr{subset(summary_table_pipi,beach_long == 'Te Haumi Beach',select = 'large_Pipi_cv')}\%) large pipi at Te Haumi Beach.  
%Whangamata Harbour also had the highest density estimate for this size class at \Sexpr{subset(summary_table_pipi,beach_long == 'Whangamata Harbour',select = 'large_Pipi_dens')} large individuals per m$^{2}$.   Density estimates were markedly lower at the other sites, with a maximum of  \Sexpr{subset(summary_table_pipi,beach_long == 'Te Haumi Beach',select = 'large_Pipi_dens')} large individuals per m$^{2}$ (at Te Haumi Beach).  
The lack or low abundance of large pipi at these sites was consistent throughout the survey series, especially in recent surveys (i.e., since \mbox{2005--06}).
At the same time, recruits ($\le$20~mm shell length) were present in all pipi populations in \mbox{2014--15}, with up to \Sexpr{ subset(LF_tab,year == '2014--15',select = 'recruits')}\% of individuals in this size class (at Eastern Beach).

%%sediment properties
At all sites, the sediment was characterised by a low organic content, which was less than 4\%.  The bulk of the sediment consisted of fine or medium sands ($>$125~\SI[detect-weight]{} to $>$250~\SI[detect-weight]{}{\micro\metre} grain size), with only a small proportion or no fines (silt and clay; $<$63~\SI[detect-weight]{}{\micro\metre} grain size).  Only individual samples at Mangawhai Harbour, Ngunguru Estuary, Ruakaka Estuary, and Te Haumi Beach exceeded 10\% in this grain size fraction, with the highest proportion of fines at 20.6\% in one sample at Te Haumi Beach. 
