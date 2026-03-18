# Retrieve and clip geozones from AIM
Last change: Vaclav Stepan, 2026-03-18

## Warning/notes
Features are clipped using clip algorithm, not intersection, so roads and railroad tracks segments are long.
The export leaves a lot to be desired in styling.
LKR311B geometry is invalid, when clipped. I don't know why. Workaround is to buffer LKR311A if needed.

## Requirements
bash, ogr2ogr, wget, awk 

## Prior to run
Adjust URL in ``1_retrieve.sh`` to get the right version of the geozones.
Find the right URL [here](https://aim.rlp.cz/?lang=en&p=uas-gz).

## Run
### Step 1: Retrieve, convert to GPKG and KML

```
./1_retrieve.sh 
```

### Step 2: Clip the geozones to required extent

To clip the geozones to one or more polygons, first create a ``clip\_by.gpkg`` with a ``clip`` layer, in EPSG:4326.
An example GeoPackage is provided.

Then, run:
```
./2_clip.sh
```

