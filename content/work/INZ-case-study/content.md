---
title: Predicting which visa applications to fast-track
short-title: Predicting which visa applications to fast-track
banner-image: /work/INZ-case-study/banner.jpg
testimonial:
  - testimonials/inz-testimonial/content.md
logo: /work/INZ-case-study/inz-logo.png
summary: Speeding up visa processing to save staff time and money
tags: systems
description: >
  The front-end triage system we built for Immigration New Zealand can
  automatically assess each visa application and speed up processing.
CTADescriptor: some text
CTAButton: read more
---

We built a prediction service to allocate visa applications to either fast track or
review track streams, based on previous decisions. Handling applications
appropriately brings faster and more reliable decision-making.

<!--more-->

### Demand for visas increasing

A labour intensive application system at Immigration New Zealand (INZ)
was requiring growing numbers of staff to meet an
increasing demand for visas. We were contracted to build a front-end triage
system to automatically assess each visa application upfront. This initial risk
assessment grades applications into those that can be safely fast tracked and
those where a more thorough investigation of the applicant
is warranted.

### Ongoing value from data

Since all applications are graded, management can decide where they place the cut-
off between fast track and review track applications. This feature of the system
allows INZ to choose a level of risk for the visa processing that meets their business
criteria. It also enables workflow and resources to be managed.

### How we did it

Analysis and predictive modelling were carried out by Dragonfly, with technical review from staff at Victoria University. We then ported
the model into the INZ operational environment, running it against a near real-time copy of their database, and delivering predictions
within 10 minutes of applications being entered into the system. The prediction service makes use of data from past applications, delivering ongoing value to Immigration New Zealand.
