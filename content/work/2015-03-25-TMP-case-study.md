---
title:  Language recognition
banner-image: /work/2015-03-25-TMP-case-study/matariki.jpg
summary: A world-first method to track the use of te reo Māori on air.
tags: systems
quote: The team at Dragonfly have been great to work with. They quickly understood what we were trying to achieve and came up with a very innovative solution. 
quote-attribution: Thomas Hood, Te Māngai Pāho
logo: /work/2015-03-25-TMP-case-study/tmp-logo.png
---

Machine learning methods are ideal for classifying streaming data rapidly. We are using these methods to help Te Māngai Pāho identify different languages broadcast by radio stations in New Zealand.  
<!--more-->

##Tracking the proportion of Māori and English spoken
Te Māngai Pāho is a government agency charged with funding and monitoring the 
Te Reo Māori (Māori language) content of iwi radio and Māori Television. 
Radio stations are funded to deliver eight hours of Te Reo content in an 
eighteen hour period which, for compliance purposes, is often delivered in specific 
blocks of time. Broadcasters, however, report that this inhibits a natural use of the 
language and drives away audiences that might enjoy a more bilingual style. 

##An automated system 
Te Māngai Pāho sought an automated and more flexible system to replace their 
labour intensive random manual monitoring system. We used machine learning methods
(in this case Recurrent Neural Networks) to develop a system that can classify radio as
either being Te Reo, English, or music. The classification is continuous (made many times
a second), and so the system is able to follow speakers as they change language and
flip between English and Māori.

##Fast and accurate language identification
A proof of concept project showed that the Recurrent Neural Network achieved over 95% accuracy in 
detecting each language and music, and was able to process three hours of audio in less than a minute.
This machine learning technique is well suited to other audio, video or streaming data classification
tasks. To train the system, a set of manually labelled data is required. Once
trained, the system is able to keep classifying new data as it arrives.

> The team at Dragonfly have been great to work with. They quickly understood what 
> we were trying to achieve and came up with a very innovative solution. 
> 
> In fact, their prototype has attracted a lot of interest nationally and internationally 
> before we have even had a chance to put it into operation.
> 
> Dragonfly took an idea and turned it into something pretty special. They made this 
> project happen for us.

<cite>Thomas Hood<br />
Manager Corporate Services<br />
Te Māngai Pāho.</cite>



