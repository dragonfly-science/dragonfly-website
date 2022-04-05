---
title: Automating data input and verification
short-title: Automating data input and verification
banner-image: /work/nms-case-study/banner.jpg
testimonial:
  - testimonials/nms-testimonial/content.md
logo: /work/nms-case-study/mfe-logo.png
summary: >
  Streamlining the processing of resource consent applications at a national
  scale
tags: capability
project-link: https://environment.govt.nz/what-government-is-doing/areas-of-work/rma/national-monitoring-system/
project-link-text: View project
description: >
  A reusable code-based system was developed to help collate data from the 40,000 resource consent applications that are made annually in New Zealand.
CTADescriptor: some text
CTAButton: read more
sortorder: 15
---

Each year, detailed data is collated by the 40,000 or so resource consent
applications made to New Zealand’s district and regional councils. This
information is critical for understanding how the resource management act is
functioning in New Zealand.

<!--more-->

## Automating the system

Councils vary greatly in their resourcing and number of applications – from Auckland to Chatham Islands – so the new system had to work right across the range.

A multi-sheet spreadsheet is sent to every council each year. The new process feeds the data from the spreadsheets into the National Monitoring System (NMS) via a series of standardisations, sense checks and verifications. The ministry then releases the collated data, which provides a national view of the year’s consenting and resource management activity.

## Custom build for flexibility

MfE were clear from the outset that a flexible approach was essential in order to cope with the dynamic nature of the overarching Resource Management Act 1991 (RMA).

The reusable code-based system we built can be adjusted easily and avoids the need for expensive changes in the future. Elements that are likely to change have been made very accessible in the code base and the rules applied to the data are written in a human readable way. This approach has also enabled new staff to learn how to use and modify the system quickly.

## Verification and sense checking

As the data from each council is fed into the NMS, rules are applied to transform it to a standard form. Things that were changed in this process are highlighted and verified by the council. Writing this process in code so it was easy for the councils to check and make changes, and for MfE to redigest those changes, was a significant piece of work.

We also coded the rules and intent of the act so they could be applied to the data. This identifies other errors in the data such as incompatible dates or consent details. The rules were written in pseudo code, translated into SQL and can be run across the dataset in seconds.

## Working as a team

Two of our staff worked on site at MfE for the first half of the project. This enabled us to get to know and support the team while they were learning how to use the code. We set up the code framework so staff with different abilities and interest in coding could contribute as they felt comfortable – some were happy to make changes to the architecture, others could edit copy and another group wrote the RMA rules. All these tasks were critically important given the pressing deadlines and small team.

MfE staff also appreciated the value of our standard reproducible approach to coding during the project – using version control and a shared code repository. Many valued it as a learning and development experience.

## The result

Automating the NMS has reduced the number of people needed to manage the annual process by about three full time staff. The staff who worked on this project are now applying their coding and data management skills to other Ministry reports and gaining efficiencies there too.

MfE is also able to release the compiled data much faster. This typically took more than a year from when the spreadsheet was sent out, because of the volume of data to process. A faster turnaround enables MfE to see how the RMA is working across the country closer to real time, and where necessary to update the policy settings in response.
