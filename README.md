# Retrieve and clip geozones from AIM
Last change: Vaclav Stepan, 2026-03-18

## Requirements
bash, ogr2ogr, wget, awk 

## Prior to run
Adjust URL in ``1_retrieve.sh`` to get the right version of the geozones.

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

