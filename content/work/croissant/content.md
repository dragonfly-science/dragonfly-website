---
title: Faster, smarter analysis of public opinion
short-title: Faster, smarter analysis of public opinion
banner-image: /work/croissant/banner.jpg
testimonial:
  - testimonials/croissant-testimonial/content.md
logo: /work/croissant/mfe-logo.png
summary: >
  Machine learning application speeds up survey text processing
tags: systems
description: >
  Machine learning application speeds up survey text processing
CTADescriptor: some text
CTAButton: read more
sortorder: 8
---

We worked with a team from the Ministry for the Environment and Ackama to
enhance the ministry’s submission processing and analysis tool, Croissant.

<!--more-->

## Public submissions are many and varied

As part of law making in New Zealand, the public may be invited to make
submissions on proposed legislation. Information gathered from submissions
guides decision-making and improves government policies.

Some consultations attract tens of thousands of submissions, which all have to
be analysed. The responses vary in form from templated submissions to email to
handwritten documents. At the end of a consultation, a summary report is produced.

## About Croissant

Croissant was built by the Department of Internal Affairs, the Ministry
for the Environment (MfE) and [Ackama](https://www.ackama.com/) to streamline
and standardise the analysis of submissions. It holds all the submissions
related to each consultation and allows their text to be analysed. While robust,
 efficient and useful in its current form, MfE is continually working to improve
  the tool.

Croissant was designed to be an all-of-government platform. It is currently
hosted by MfE and has been made available to a limited number of other agencies.
 Its use could be extended to all government agencies in the future.

## Tagging submissions for analysis

Within Croissant, submission text is tagged with keywords that reflect its
content. Tags highlight themes mentioned in each submission so they can be
clearly identified, then sorted and analysed. Tagging also allows submissions
from specific groups (such as companies, iwi or regions) to be identified and
considered appropriately.

The Croissant dashboard shows the status of different consultations, the
submissions themselves and how much of the text has been tagged. Information
about the number of tags applied, alongside examples of tagged text can be
produced to add to the consultation report.

## Meeting a niche need

Applying tags to submission text within Croissant has historically been a slow,
 manual process. MfE identified a need to improve this process but found no
 suitable applications – only expensive, stand-alone tools lacking transparency
 were available.

Dragonfly Data Science was then approached to develop a machine learning
(artificial intelligence) module to automate the tagging. What we built fits
with Croissant’s existing information architecture. It processes text
automatically in parallel with the manual tagging.

## Module operates in two different modes

In an unsupervised mode, the machine learning module identifies groups of
submissions that contain similar ideas. The main themes within each group are
also identified.

This mode provides an overview of a large body of text without requiring human
intervention. The module creates an interactive map of all submissions, with
similar submissions grouped together. These results can help to develop tags
that are appropriate for all the submission text.

In a supervised learning mode, the module is taught to associate manually
applied tags with specific text under review. It then automatically applies
those same tags to the remaining untagged text.

Automatic tagging can be triggered at any time during the manual text
processing. After tagging, the text can be analysed by a variety of other
programmes.

## Security and transparency were essential

Croissant is helping to facilitate genuinely democratic public processes. The
use of open source libraries and data formats means that the results are easily
accessible by analysts rather than being locked away in a proprietary format.
The module is also structured in a way that guarantees the security of every
submitter’s personal information.

## Low cost allows for more opinions

Croissant has a low running cost compared with some other submission analysis
tools. This makes it possible for the government and other organisations to
gather public opinion on a wider range of topics.

Using a machine learning approach saves time by enabling a faster turnaround
from the close of submissions to the consultation report. Also, because this
automated approach easily scales to manage large quantities of text, every
single submission can be analysed, and no idea is left behind.

## A good, imperfect solution and next steps

The solution we developed is not perfect, or intended to be perfect. However,
MfE estimates that using our module is saving about 80–90 percent of the time
taken to manually tag submissions.

It is also anticipated that the project will have paid for itself after 12
consultations because of the faster tagging, analysis and report production.

Machine learning opens up a wide range of possible future improvements like
being able to include audio submissions or submissions in other languages. We
are working on both of these ‘wish list’ items.

A future enhancement is to provide text analysis inside the tool itself, which
would enable high level analysis to be presented in the consultation report.

## Project team

[Richard Mansfield](/people/mansfield-richard.html),
[Ignatius Menzies](/people/menzies-ignatius.html),
[Yvan Richard](/people/richard-yvan.html),
[Finlay Thompson](/people/thompson-finlay.html).

### More information

[Read a story about the initial development and funding of Croissant](https://www.digital.govt.nz/showcase/a-recipe-for-cross-agency-innovation-croissant/).
