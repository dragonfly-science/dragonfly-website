---
title: Cyclone Gabrielle flooding - updated data
---

An initial map of flooding in Hawke’s Bay used synthetic aperture radar data we prepared from the Sentinel-1 satellite on Tuesday 14 February. This data has now been updated with information from the Sentinel-2 satellite.  

<!--more-->

**Sentinel-2 and Sentinel-1 data and map**
The updated data was prepared using before and after images of vegetation, based on the normalised difference vegetation index. This index picks up changes in vegetation, soil and water, which highlighted new silt, slips and inundated areas.

The before images were from 5 January–10 February 2023 and the after images were from 19 and 21 February 2023. Some areas of cloud may remain in the Sentinel-2 dataset despite our cloud removal processing.

The data is available for download below.

**Sentinel-1 data and map**
Synthetic aperture radar (SAR) data isn’t affected by darkness or cloud cover. This enabled the water levels to be captured at 8.07pm on Tuesday 14 February – when the satellite happened to be overhead.

![Extent of flooding near Napier on Tuesday 14 February at 8.07 pm. Flooded areas are coloured blue.](/news/2023-02-17-cyclone-gabrielle/napier-flooding.jpg)

Dragonfly data scientist [Sadhvi Selvaraj](/people/selvaraj-sadhvi.html)located and analysed the Sentinel-1 and Sentinel-2 data.

“The initial map doesn’t show the full extent of the flooding – only the flooding that had occurred by the time the satellite image was recorded. Also, the map hasn’t been validated by what we’ve seen on the ground.”

[Ian Reese](/people/reese-ian.html) created the maps using QGIS. The imagery was processed in Google Earth Engine, using methods based on those recommended by the [United Nations Platform for Space-based Information for Disaster Management and Emergency Response](https://www.unoosa.org/oosa/en/ourwork/un-spider/index.html).

Sadhvi says SAR data is useful for mapping floods in open areas, but may not accurately show flooding in urban areas.

"That’s because the data is acquired by sensors that send and receive microwave signals at a slant angle, so buildings can block the signals and create inaccuracies.”

“Our hearts go out to those who have lost homes, livelihoods and incomes in the flooding. I experienced the unprecedented Auckland floods a couple of weeks ago, but what’s just happened in parts of Hawke’s Bay is absolutely devastating.

"I can only hope that sharing this data and showcasing the technology will inform our planning for emergency rescue efforts and reduce the terrible effects of future storms like Gabrielle.”

Email [Sadhvi Selvaraj](mailto:sadhvi@dragonfly.co.nz) to find out more about satellite imagery and technical details of the analyses.
---
More information

* [Download the updated data based on changes in vegetation](s3://swa-flood-mapping/data/vector/HB_GISB/FAA_S1_S2_19-21Feb2023_noCloud_categorised_attrib.gpkg).
* [Download the initial Hawke’s Bay flood map data](https://files.dragonfly.co.nz/data/hawkes-bay-flood/hawkes-bay-flood-2023-02-14.zip).
* [Browse Sentinel-1 satellite data](https://apps.sentinel-hub.com/eo-browser/?zoom=11&lat=-39.59537&lng=176.71783&themeId=DEFAULT-THEME&visualizationUrl=https%3A%2F%2Fservices.sentinel-hub.com%2Fogc%2Fwms%2Ff2068f4f-3c75-42cf-84a1-42948340a846&datasetId=S1_AWS_IW_VVVH&fromTime=2023-02-14T00%3A00%3A00.000Z&toTime=2023-02-14T23%3A59%3A59.999Z&layerId=IW-DV-VV-DECIBEL-GAMMA0-RADIOMETRIC-TERRAIN-CORRECTED&demSource3D=%22MAPZEN%22).
* [Read the story in the New Zealand Herald](https://www.nzherald.co.nz/nz/cyclone-gabrielle-floods-first-satellite-images-shows-extent-of-hawkes-bay-flooding/TX5QMIEM2JBRTKSH5PKTTECTSE/).
* [Read more about QGIS mapping](news/2023-01-17-web-mapping-software.html).

The flood map data for urban and non-urban areas is provided separately in Shapefile and Geopackage formats and released under a [Creative Commons Attribution-ShareAlike 3.0 IGO](https://creativecommons.org/licenses/by-sa/3.0/igo/)licence.
