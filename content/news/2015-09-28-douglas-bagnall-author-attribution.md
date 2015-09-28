---
title: Author prediction win for Douglas 
---

Dragonfly associate Douglas Bagnall recently won a software competition to correctly predict the 
author of 100 or more pieces of text in each of four languages. The evaluation lab competition 
is run annually as part of the [PAN conference](http://www.uni-weimar.de/medien/webis/events/pan-15/pan15-web/), (plagiarism, authorship and social software 
misuse). In 2015 there were 18 entries, including some from large university research 
groups.

<!--more-->

Douglas’ interest in author identification began with a curiosity about the writers of the 
controversial Whale Oil blog. 

“When Dirty Politics came out, I wanted to find a way to identify the author of a blog post, 
because it was thought that various people were writing the posts anonymously on behalf of 
corporations and politicians. I decided to use a recurrent neural network, which works by 
predicting what the next character is most likely be, based on what had been written so far.”

Describing himself as an artist who writes software that makes art, Douglas first used a 
recurrent neural network in a video installation that was part of the [Among the Machines]( 
http://dunedin.art.museum/exhibitions/future/australian_and_nz_artists) exhibition at the 
Dunedin Public Art Gallery in 2013. 

The human brain is the most powerful recurrent neural network, made up of a network of 
neurons that communicate with each other. Like the brain, artificial neural networks can 
improve their accuracy by being trained to recognise certain features of a medium. 

“After the exhibition I had no money and no job. When I walked into Dragonfly, Edward asked 
me what he should use to identify kiwi calls from a recording. I said a recurrent neural network 
because that’s what I was doing at the time. We made it work for kiwi calls, then moved from 
there onto the Māori language work.” (Read about the [Kōkako language recognition system](/news/2015-09-04-kokako-launch.html)).

Douglas found out about the author identification competition in March, and had two months 
to prepare his entry. Each entrant wrote software that was  given between one 
and five text samples by each of hundreds of authors, and had to decide whether 
an unknown text had been written by the same person or not. This year the task was 
made trickier by using texts from different genres such as an essay and a product review. 

“Some samples were only about 300 words long, so my original system wouldn’t have 
worked. I made a modification where a network was simultaneously learning to model all the 
authors at once by modelling the language as a whole and picking out bits that suited each 
author.”

Other competitors extracted thousands of features from the text, (e.g., the number of words 
over six letters, the number of times a sequence of words occurs) and used a supercomputer 
to compare them using a vector space. Douglas’ alternative method, however, 
cleverly reduced the number of text features without losing any information. 

“The vector space method requires you to decide ahead of time what text features you will 
use for each language, and then disregard the rest. My network was trained to pay attention 
to every little part of the text and not prematurely throw away any information. It turns out that 
nobody else uses recurrent neural networks in this way as far as we know. They are quite 
new.” 

Douglas says he will probably have another go at the competition next year. In the meantime 
he is presenting his work to the linguistic departments in New Zealand universities, where 
there is growing interest in computational linguistics. 

Read a paper describing Douglas’s system: [Author Identification using multi-headed Recurrent Neural Networks](http://www.uni-weimar.de/medien/webis/events/pan-15/pan15-papers-final/pan15-authorship-verification/bagnall15-notebook.pdf).

Douglas's software Recur is [openly available](https://github.com/douglasbagnall/recur).
