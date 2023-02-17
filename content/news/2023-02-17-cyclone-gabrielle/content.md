---
title: Mapping flooding from Cyclone Gabrielle with satellite data
---

Flooding from Cyclone Gabrielle has devastated regions of Hawke's Bay. Satellite
data allow for a rapid preliminary assessment of the extent of the flooding. In order to help
with the response, we are releasing flooding data derived from a Copernicus Sentinel-1 satellite.
The satellite imagery was collected on Tuesday, February 14, at 8.07pm. It does not indicate the full extent
of the flooding, and has not been validated on the ground.   
<!--more-->

A map of the flooding from Cyclone Gabrielle published by The Herald. The data may be downloaded [here]().
<div class="flourish-embed flourish-photo-slider" data-src="visualisation/12464013"><script src="https://public.flourish.studio/resources/embed.js"></script></div>


The flood extent layer was derived from SAR (synthetic aperture
radar) data, capture at a single point in time. SAR data is
well suited for mapping floods since the data acquisition is possible regardless of the cloud cover 
and SAR images can be captured day and night. This is not possible 
when using multispectral (colour) data such as Sentinel-2.

While SAR data can be used for mapping floods in open areas, flooding in urban areas may not be shown accurately. The 
SAR data is acquired by sensors that send and receive microwave signals at a slant angle and different 
polarisations (the way the microwave signals are orientated when they are sent and received). This 
is unlike other multispectral  data acquisition where you see images observed top 
down. This slant angle in SAR acquisition would mean there will be some buildings in the urban 
areas that block the signals from passing through resulting in radar shadow. 
The analysis technique used for mapping floods in open areas cannot be applied for urban areas 
unless the buildings were fully submerged. 

For more information about the satellite data contact Dr Sadhvi Selvaraj [sadhvi@dragonfly.co.nz](mailto:sadhvi@dragonfly.co.nz).

---
More information  

* [Browse the Sentinel satellite data](https://apps.sentinel-hub.com/eo-browser/?zoom=11&lat=-39.59537&lng=176.71783&themeId=DEFAULT-THEME&visualizationUrl=https%3A%2F%2Fservices.sentinel-hub.com%2Fogc%2Fwms%2Ff2068f4f-3c75-42cf-84a1-42948340a846&datasetId=S1_AWS_IW_VVVH&fromTime=2023-02-14T00%3A00%3A00.000Z&toTime=2023-02-14T23%3A59%3A59.999Z&layerId=IW-DV-VV-DECIBEL-GAMMA0-RADIOMETRIC-TERRAIN-CORRECTED&demSource3D=%22MAPZEN%22).
* [Download the Hawke's Bay flood map data]().
