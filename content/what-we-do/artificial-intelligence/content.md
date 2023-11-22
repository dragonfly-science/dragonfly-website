---
title: Artificial intelligence
subtitle: >
  Recent progress toward artificial intelligence has enabled a host of new research, and augmented or improved existing approaches in several existing domains. Dragonfly has spent many years keeping abreast of the latest machine learning techniques, and applying them across a range of interesting projects.
teaserTitle: Artificial intelligence
teaserSVG: /what-we-do/artificial-intelligence/WWD_Learning1.svg
bannerSVG: /what-we-do/martificial-intelligence/WWD_Learning2.svg
description: >
  How we apply artificial intelligence to a broad range of projects in our work.
teaserIntro: >
  At Dragonfly, we use artificial intelligence to advance scientific research and discovery. With over a decade of experience leveraging AI to solve complex problems, our team of data scientists are experts in a variety of machine learning applications, from computer vision to natural language processing and speech recognition. 
teaserCTAbutton: Read more
teaserAnchorId: artificial-intelligence
sortorder: 1
tiles:
  - work/croissant/content.md
  - work/vibrant-planet/content.md
  - work/TMP-case-study/content.md
  - work/technical-review-case-study/content.md
---

Whether you need AI for analysing satellite imagery, genomic sequences, field-recorded birdsong, or underwater video, our innovative algorithms and models can help accelerate your research. Partnering with us gives you access to the latest AI capabilities so you can extend the boundaries of what can be achieved with your data.

While we enjoy prototyping bespoke models from scratch, we are equally adept at finetuning, engineering, and production. Our team trains models on specialised GPU clusters, and runs inference on everything from API-equipped servers to mobile devices. When it comes to 'ML Ops' -- including keeping track of experiments, datasets, pipelines and models -- our 'reproducible' philosophy is a significant asset. 

The below sections highlight some of our work to date in selected areas.

# Computer Vision

The use of AI to solve computer vision problems has become ubiquitious in the era of GPU acceleration. Bespoke deep neural networks to solve standard problems (object detection, segmentation, classification etc.) are now being replaced by transformer-based multimodal models that allow vision tasks to incorporate text or even audio prompts.

Dragonfly recently used computer vision to help develop a synthetic canopy height model (CHM) with Vibrant Planet, a California-based organisation which builds land management tools to mitigate climate change. After aligning NAIP satellite imagery with USGS airborne laser scanning (ALS) data, we trained a U-Net architecture adapted for monocular depth estimation to model the derived CHM, and subsequently built a pipeline for running this model across California. This work will be explained in more detail in an upcoming preprint, *A synthetic Canopy Height Model to fill ALS survey
gaps*, co-authored by Dragonflies Fabian Döweler, Ian Reese, Henry Macdonald and Sadhvi Selvaraj.

Another project involved using computer vision to identify black petrel in video footage recorded on fishing vessels. This work, a collaboration with David Middleton of Pisces Research and led by Dragonfly Henry Zwart, aimed to investigate whether object detection models could be trained to identify birds snared in fishing lines. The final model achieved recall rates similar to human expert reviewers, but could be run 30 times faster.

We have also been using computer vision to analyse underwater video for Environment Agency - Abu Dhabi (EAD), as part of the Fisheries Resources Assessment Survey (FRAS). Hundreds of hours of underwater video data have been collected by EAD during trawl surveys, which presents an opportunity to develop novel, non-lethal methods for estimating fish populations in the Arabian Sea and Gulf of Oman. We have engaged a team of subject matter experts to detect fish in the video and identify individual species of interest, and are using the resulting dataset to train object detection and object tracking models - the latter of which enables counting samples without human intervention. This work is ongoing.


# Speech Recognition

AI has made major inroads into speech recognition (also known as speech-to-text or STT); the days of Hidden Markov models and separate phonetic, acoustic, and language models are long gone. In the latest generation of models, such as OpenAI's Whisper, significant progress has even been made on the tricky problem of understanding the New Zealand accent!

Dragonfly first became involved in neural network-based speech recognition back in 2015, when we built the Kōkako platform for Te Māngai Pāho, New Zealand’s Māori broadcasting agency. This allowed iwi radio stations to have segments of spoken and sung te reo Māori automatically detected in their programme material, sparing the considerable manual analysis that was previously necessary to meet their funding conditions.

Continuing the te reo Māori theme, Dragonfly partnered with Northland-based Te Hiku Media in 2019 to develop a state-of-the-art Māori speech recognition model. This involved hundreds of hours of labelled te reo speech data, contributed by native speakers in Te Hiku's rohe, and used the then-bleeding edge Deepspeech architecture. This model and partnership created a future basis for research into pronunciation, under the umbrella of the MBIE-funded Papa Reo data science platform.

In 2022, Dragonfly built a New Zealand English speech recognition prototype with the Ministry of Transport, supported by a government Innovation Fund award. This involved working with our front-end team to build an app, Aotearoa Speaks, that could be used for verbal public consultations. The underlying model was shown to understand a range of recordings in NZ English, including loanwords and placenames from te reo Māori.

# Language Models and NLP

Large language models (LLMs) have been at the heart of the most recent surge of interest in AI, described as a 'boom' by market analysts. These are huge generative models (with over 100 million parameters) trained on petabytes of text data, which can be used for a plethora of NLP tasks - from predicting missing words, to chat (e.g. ChatGPT), to freeform creative writing.

Dragonfly's work on language models precedes this recent flurry of public attention. In our work with Te Hiku Media, we trained language models on freely available te reo Māori data. Dragonfly Yvan Richard has also applied machine learning to public submission analysis for the Ministry for the Environment. The tools he developed -- which integrate with Croissant, a submissions analysis tool with all-of-government potential -- allow for automated tagging of submissions, with both unsupervised and supervised modes.

Given the shift to LLMs, we have begun to update our workflows to work downstream, leveraging prompt engineering to perform a range of NLP tasks. We are also interested in the proliferation of open source models, such as Meta's LLama, many of which can be run on more modest hardware with quantisation and domain-specific finetuning - even local CPUs. In time, we hope this will address the cost and data sovereignty issues associated with the 'foundation models' paradigm.
