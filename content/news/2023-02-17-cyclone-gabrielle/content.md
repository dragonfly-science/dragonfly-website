---
title: Mapping flooding from Cyclone Gabrielle with satellite data
---

Flooding from Cyclone Gabrielle has devastated regions of Hawke's Bay. Satellite
data allow for a rapid preliminary assessment of the extent of the flooding. In order to help
with the response, we are releasing flooding data derived from a Copernicus Sentinel-1 satellite.
<!--more-->

A map of the flooding from Cyclone Gabrielle in Hawke's Bay was published by [The Herald](https://www.nzherald.co.nz/nz/cyclone-gabrielle-floods-first-satellite-images-shows-extent-of-hawkes-bay-flooding/TX5QMIEM2JBRTKSH5PKTTECTSE/). 
The data underlying this visualisation may be downloaded [here](https://files.dragonfly.co.nz/data/hawkes-bay-flood/hawkes-bay-flood-2023-02-14.zip).

<div class="flourish-embed flourish-photo-slider" data-src="visualisation/12464013" data-width="80%"><script src="https://public.flourish.studio/resources/embed.js"></script></div>


The flood extent layer was derived from SAR (synthetic aperture
radar) data, collected on Tuesday, February 14, at 8.07pm. 
It does not indicate the full extent of the flooding: only the flooding that had occurred by the time of the 
satellite image. The flood map has not been validated on the ground.   

SAR imagery is
well suited for mapping floods since the data acquisition is possible regardless of the cloud cover 
and SAR images can be captured day and night. This is not possible 
when using multispectral (colour) data such as from the Sentinel-2 satellite.While SAR data can be used for 
mapping floods in open areas, flooding in urban areas may not be shown accurately. The 
SAR data is acquired by sensors that send and receive microwave signals at a slant angle and different 
polarisations (the way the microwave signals are orientated when they are sent and received). This 
is unlike other multispectral  data acquisition where you see images observed top 
down. This slant angle in SAR acquisition would mean there will be some buildings in the urban 
areas that block the signals from passing through resulting in radar shadow. 
The analysis technique used for mapping floods in open areas cannot be applied for urban areas 
unless the buildings were fully submerged. 


The flood map data are provided seperately for urban and non-urban areas, in Shapefile and Geopackage formats. 
The flood map dataset is released under a [Creative Commons Attribution-ShareAlike 3.0 IGO](https://creativecommons.org/licenses/by-sa/3.0/igo/) licence. 

For more information about satellite imagery contact Dr Sadhvi Selvaraj [sadhvi@dragonfly.co.nz](mailto:sadhvi@dragonfly.co.nz).

---
More information  

* [Download the Hawke's Bay flood map data](https://files.dragonfly.co.nz/data/hawkes-bay-flood/hawkes-bay-flood-2023-02-14.zip).
* [Browse the Sentinel satellite data](https://apps.sentinel-hub.com/eo-browser/?zoom=11&lat=-39.59537&lng=176.71783&themeId=DEFAULT-THEME&visualizationUrl=https%3A%2F%2Fservices.sentinel-hub.com%2Fogc%2Fwms%2Ff2068f4f-3c75-42cf-84a1-42948340a846&datasetId=S1_AWS_IW_VVVH&fromTime=2023-02-14T00%3A00%3A00.000Z&toTime=2023-02-14T23%3A59%3A59.999Z&layerId=IW-DV-VV-DECIBEL-GAMMA0-RADIOMETRIC-TERRAIN-CORRECTED&demSource3D=%22MAPZEN%22).

