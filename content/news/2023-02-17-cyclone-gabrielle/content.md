---
title: Cyclone Gabrielle flooding mapped
---

The New Zealand Herald published a map of recent flooding in Hawke’s Bay using synthetic aperture radar data we prepared from the Sentinel-1 satellite.

<!--more-->

Synthetic aperture radar (SAR) data isn’t affected by darkness or cloud cover. This enabled the water levels to be captured at 8.07pm on Tuesday – when the satellite happened to be overhead.

![Extent of flooding near Napier on Tuesday 14 February at 8.07 pm. Flooded areas are coloured blue.](/news/2023-02-17-cyclone-gabrielle/napier-flooding.jpg)

Dragonfly data scientist [Sadhvi Selvaraj](/people/selvaraj-sadhvi.html) located and analysed the satellite data, which she says provides an indication of the extent of the flooding at the time.

“The map doesn’t show the full extent of the flooding – only the flooding that had occurred by the time the satellite image was recorded. Also, the map hasn’t been validated by what we’ve seen on the ground.”

[Ian Reese](/people/reese-ian.html) created the maps using QGIS. The imagery was processed in Google Earth Engine, using methods based on those recommended by the [United Nations Platform for Space-based Information for Disaster Management and Emergency Response](https://www.unoosa.org/oosa/en/ourwork/un-spider/index.html).

“SAR data is useful for mapping floods in open areas, but it may not accurately show flooding in urban areas. That’s because the data is acquired by sensors that send and receive microwave signals at a slant angle, so buildings can block the signals and create inaccuracies.”

“Our hearts go out to those who have lost homes, livelihoods and incomes in the flooding. I experienced the unprecedented Auckland floods a couple of weeks ago, but what’s just happened in parts of Hawke’s Bay is devastating.

"I can only hope that sharing this data and showcasing the technology will inform our planning for emergency rescue efforts and reduce the terrible effects of future storms like Gabrielle.”

Email [Sadhvi](mailto:sadhvi@dragonfly.co.nz) to find out more about satellite imagery.

---
More information

*[Download the Hawke’s Bay flood map data](https://files.dragonfly.co.nz/data/hawkes-bay-flood/hawkes-bay-flood-2023-02-14.zip).
*[Read the story in the New Zealand Herald](https://www.nzherald.co.nz/nz/cyclone-gabrielle-floods-first-satellite-images-shows-extent-of-hawkes-bay-flooding/TX5QMIEM2JBRTKSH5PKTTECTSE/)
*[Browse the Sentinel satellite data](https://apps.sentinel-hub.com/eo-browser/?zoom=11&lat=-39.59537&lng=176.71783&themeId=DEFAULT-THEME&visualizationUrl=https%3A%2F%2Fservices.sentinel-hub.com%2Fogc%2Fwms%2Ff2068f4f-3c75-42cf-84a1-42948340a846&datasetId=S1_AWS_IW_VVVH&fromTime=2023-02-14T00%3A00%3A00.000Z&toTime=2023-02-14T23%3A59%3A59.999Z&layerId=IW-DV-VV-DECIBEL-GAMMA0-RADIOMETRIC-TERRAIN-CORRECTED&demSource3D=%22MAPZEN%22).
*[Read more about QGIS mapping](news/2023-01-17-web-mapping-software.html).

The flood map data for urban and non-urban areas is provided separately in Shapefile and Geopackage formats and released under a [Creative Commons Attribution-ShareAlike 3.0 IGO](https://creativecommons.org/licenses/by-sa/3.0/igo/)licence.
