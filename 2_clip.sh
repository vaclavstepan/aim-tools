#!/bin/bash
set -euo pipefail

TODAY=$(date +'%Y-%m-%d')

DDIR=${TODAY}
EDF=geozones_geojson.zip
CLIPSRC=clip_by.gpkg
CLIPLAYER=clip

# Convert every JSON in the target dir to GPKG layer, assigning EPSG:4326 to it
GPKG=${DDIR}/$(basename $EDF .zip).gpkg

# Clipped layers go to tmp:
CLIPPEDGPKG=${DDIR}/$(basename $EDF .zip)_clipped_all.gpkg

rm -v -f $CLIPPEDGPKG

# For each layer
echo Clipping from $GPKG to $CLIPPEDGPKG

for l in $(ogrinfo -al -so $GPKG | \
awk -F': ' '/^Layer name:/{layer=$2; print layer}')
do
  echo $l
  ogr2ogr -f GPKG -update -overwrite -nlt MULTIPOLYGON -clipsrc $CLIPSRC -clipsrclayer $CLIPLAYER -makevalid $CLIPPEDGPKG $GPKG $l
  ogrinfo $CLIPPEDGPKG
done

# Now, only copy non-empty layers to the resulting gpkg
NZGPKG=${DDIR}/$(basename $EDF .zip)_clipped.gpkg
if [[ -f $NZGPKG ]] ; then
  rm $NZGPKG
fi

echo "Copying non-empty layers to $NZGPKG"

for l in $(ogrinfo -al -so $CLIPPEDGPKG | \
awk -F': ' '
/^Layer name:/ {layer=$2}
/^Feature Count:/ {if ($2+0 > 0) print layer}
')
do
  echo $l
  ogr2ogr -f GPKG -update -overwrite $NZGPKG $CLIPPEDGPKG $l
done

echo "---> Converting to KML"
# Create KML versions of the JSONs
KMLDIR=${DDIR}/KML-Clipped
mkdir -p $KMLDIR

for l in $(ogrinfo -al -so $NZGPKG | \
awk -F': ' '
/^Layer name:/ {layer=$2}
/^Feature Count:/ {if ($2+0 > 0) print layer}
')
do
  echo $l
  ogr2ogr -f KML $KMLDIR/${l}.kml $NZGPKG $l -mapFieldType DateTime=String
done

# Zip the KMLs to an archive
( cd $DDIR && zip -r kml-clipped.zip $(basename $KMLDIR) )

# List outputs

echo 
echo Outputs:
echo -------
echo Clipped KML files as ZIP archive: $DDIR/kml-clipped.zip
echo GeoPackage with clipped geozones: $NZGPKG
