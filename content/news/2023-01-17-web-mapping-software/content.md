---
title: In-house innovation creates more useful, beautiful maps
---

Frustrated with the limitations of current web mapping software, Dragonfly’s
digital cartographer Ian Reese set about making
something better. Now this new method is being rolled out to our clients.

<!--more-->

Ian says he was irritated at being stuck using outdated and unsupported software
to handle raster data. (Raster data is pixelated data where each pixel
represents a specific geographical location.)

“In the last 10 years, web mapping software has moved on from stacked raster
tiles to [vector tiles](https://en.wikipedia.org/wiki/Vector_tiles). In this
transition, the capabilities of handling multiple raster datasets in web mapping
applications have been lost.”

“The real difficulty was the inability to work with quality scientific data,
usually in raster format, and get it to the web in an aesthetically pleasing
format. Current web mapping software and methods do not make that easy.”

Ian started looking into a solution during the 2020 lockdown. “I had time then
to really dig into the problem, but there was a long series of roadblocks to get
through.”

“Vector tiles are more efficient and certainly have a place in web mapping, but
the need for integrating raster data has not diminished. The difficulty has been
bringing vector and raster data together while effectively blending the two data
types for use on the web.”

Ian says he looked at a lot of commercial web mapping software but couldn't find
anything to replace the old method for creating raster tiles with blending
capabilities. For a while he contemplated writing code to do it himself.

“Solving this problem was the hardest part of the project. In the end, I decided
I didn't need to reinvent the wheel and looked to [QGIS](https://qgis.org/en/site/)
and [GDAL](https://gdal.org) to make it work. QGIS did most of what I needed in
visualisation, setting zoom rules and blending data, and the Cloud Optimized
GeoTIFF (COG) format looked like it could potentially replace the need for raster
tiles. I just needed to devise a method to turn QGIS rules into a COG."

![Screenshot of the set-up in QGIS.](/news/2023-01-17-web-mapping-software/mapping-screenshot.jpg)

The next challenge was working the COG into a pseudo raster tile cache, similar
to the old mbTile format.

“COGs are not really meant to act in this way and it was new territory for me.
COGs were developed to take a single raster and prep them for the web by
restructuring the internal format of the file.(The file is rebuilt internally
with a tiled pyramid structure that looks like the old raster tile cache.)

“However, COGs work exceptionally well with aerial imagery, so my reasoning was
that if COGs can handle RGB images, it shouldn’t matter what that image is, as
long as it follows the method of the internal COG structure. I thought this
approach had potential to solve the problem and save me a lot of time.”

Ian was able to use QGIS, PyQGIS and GDAL to wrap the method together. It
exports a web-ready map with the specified features and zoom rules – conveniently
as a COG. He says the method works surprisingly well, though there are still a few
wrinkles to iron out.

The result is a single raster file that displays all the built-in zoom rules.
It works seamlessly on the web and with QGIS. Ian couldn't be happier with the
results.

“We've already started to integrate this process into our workflows. It’s been
especially helpful when we needed a basemap for the web or to pass around for
our scientists. The method keeps the map consistent for all our users since
they’re working the same base image.”

“There’s also no need for specialised software or methods to read the map. The
GeoTIFF format is pretty universal in the geospatial community and most software
can handle it.”

Ian presented this research at the [Pacific Geospatial Conference](https://www.osgeo.org/events/pacific-geospatial-conference-2022/) in Fiji in November 2022. He is a member of the
FOSS4G (free and open software for geospatial) community and invites others to work with him on improving the
method.

---

More information

- [Read a technical description of this work](https://xycarto.com/2022/11/26/qgis-to-stylized-cogs/).
- [See a demonstration of the method](https://dragonfly-science.github.io/qgis-cog-tiler/).
- [View the Github repository](https://github.com/dragonfly-science/qgis-cog-tiler).
