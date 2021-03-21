---
title: Calculating drive times in Stata using the osrmtime command
author: James Thomas
date: '2021-03-21'
slug: calculating-drive-times-in-stata-using-the-osrmtime-command
categories:
tags: 
  - osrmtime
  - stata
description: ''
keywords:
  - osrmtime
  - stata
toc: true
highlight: tango
---

This post walks through the (somewhat fiddly) installation and usage of the `osrmtime` command. It is a Stata command for calculating **distances** and **travel times** between two sets of GPS coordinates on a map.

This is done using: 

- ***OpenStreetMaps*** for your map (which you are required to download before running the command such that everything works totally offline)
- the **Open Source Routing Machine ("OSRM")** to determine the shortest distance between A and B
	
If you have the time to spare, I would read the `osrmtime` [author guide](https://www.uni-regensburg.de/wirtschaftswissenschaften/vwl-moeller/medien/huber/osrm_paper_online.pdf) (it's only 7 pages), but if not, this post is self-contained.

Note, *OpenStreetMaps*'s maps "**are not validated** by a general authority like the maps of a commercial provider, but are recorded and maintained by users in a decentralized fashion" (quote from author guide).

The advantage of this is that the `osrmtime` command is **totally free** to use, unlike other options for calculating distances and drive times (like the Google Distance Matrix API or ArcGIS).

## Installation

The links for installing the routing software in the above pdf no longer work. Instead, go to: 

<https://github.com/christophrust/osrmtime/blob/master/README.md>
	
and click on the 'release archive' hyperlink. Once the .zip file has downloaded, right click on it and select 'Extract all...'

Once you have unpacked the content of the release archive, run the following from the Stata command line (replacing INSERT_PATH with the path to your downloaded files): 	


```stata
net describe osrmtime, from("INSERT_PATH")
```

This shows you the 'installation' and 'ancillary' files for the package. To download these, run the following from the command line:


```r
net install osrmtime
net get osrmtime
```

## Preparing your map

The point of this command is that you do not need to rely on third parties/the internet to calculate distances/drive times. Of course, you still do rely on these to download your map, but once you have done this, the program no longer requires an internet connection to do all of its various calculations.

The first step is to go to the following address and download a .osm.pbf map file (of course if you are not looking at the UK, don't download the file at this precise link):

<https://download.geofabrik.de/europe/britain-and-ireland.html>

Before you start playing around with the map however, you need to unpack the .zip file inside your download of the release archive (which you downloaded in the 'Installation' section). It should be called:

>	<font size="2">osrm_win_v5.14.zip</font>

Right click on this and select 'Extract all...'. You should take note of where you save this extracted file, as you will need it for the next step.

The next step is to clean/prepare the file for use by the OSRM. Contained in the files you downloaded is the `osrmprepare` command which will help you with this. You need to run the following (which takes a while):


```r
osrmprepare, ///
	mapfile("INSERT_PATH") /// // path to the .osm.pbf map downloaded
	osrmdir("INSERT_PATH") /// // path to the OSRM executables
	profile(car) // type of map you would like to produce
```

Again, insert your own paths. For additional options, see the help file. 

There are several elements of the above that need a bit of additional explanation:

Firstly, the path to the map **cannot contain any spaces**. In my case at work this meant that I could not save the map in one of our standard project folders (as these are all named "PROJECT_NAME (PROJECT_CODE)", which contains a space). Apart from that, the first line is fairly self-explanatory.

Next is the path to the OSRM executables. This is the second folder you unzipped. Remember that your path should end with a "\\". In my case the path was:

> <font size="2">C:\\Users\\james.thomas\\Downloads\\osrmtime_release1.3.3\\osrm_win_v5.14\\</font>

The last option is simply what type of routes you would like the map to be prepared for. This can be either **car**, **bicycle**, or **foot**.

When the command has finished running, you will find around two dozen new files saved inside the same folder as your .osrm.pbf map. Most importantly, you will find a **.osrm file**. This is what you will use as your input for the `osrmtime` function.

## Calculating drive times
	
The `osrmtime` command has the following syntax:


```r
osrmtime lat1 lon1 lat2 lon2, ///
  mapfile("INSERT_PATH") /// // path to the .osrm map file produced above
  osrmdir("INSERT_PATH") // same path as for osrmprepare
```

You will note that for this to work you will need each observation in your dataset to be an origin-destination pairing.

For the UK, a great resource to get latitude/longitude data is the [*National Statistics Postcode Lookup ("NSPL")*](https://geoportal.statistics.gov.uk/datasets/national-statistics-postcode-lookup-february-2021) (this links to the February 2021 edition- it is updated every 3 months). This has the GPS coordinates of every postcode in the UK. Of course, this is only useful if you have postcodes...
	
In terms of the output of the command, the following variables are generated:

- `distance` (in metres)
- `duration` (in seconds)
- `jumpdist1` (in metres)
- `jumpdist2` (in metres)
- `return_code` (`0` = everything fine, `1` = no route found,	`2` = OSRM did not respond,	`3` = something else went wrong)

`jumpdist1` (`jumpdist2`) shows the distance between the origin (destination) coordinates and the nearest point on a road from which the calculation of the distance/travel time starts (ends). If this variable is very large, this could be an indication of an incomplete map.
