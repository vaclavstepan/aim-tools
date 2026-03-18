#!/bin/bash
set -euo pipefail

TODAY=$(date +'%Y-%m-%d')

DDIR=${TODAY}
EDF=geozones_geojson.zip
URL="https://aim.rlp.cz/data/uas/2026_03_05/actual/geozones_geojson.zip"
ED=${DDIR}/${EDF}

# Target JSON dir"
JSDIR="${DDIR}/JSON"

echo Fetching archive $ED
if [[ -f $ED ]]; then
  echo " $ED already exists, reusing."
else
  mkdir -p $DDIR
  wget -O $ED $URL
fi

if [[ -d $JSDIR ]]; then
  echo "  JSON dir $JSDIR already exists, skipping unpacking."
else
  mkdir $JSDIR
  unzip $ED -d $JSDIR
fi

# Verify presence of expected extracted subdir
if [[ -d "$JSDIR" ]]; then
  echo " $JSDIR JSON dir found."
else
  echo " JSON dir not found"
  exit 1
fi

# Convert every JSON in the target dir to GPKG layer, assigning EPSG:4326 to it
GPKG=${DDIR}/$(basename $EDF .zip).gpkg

echo "---> Converting to GPKG"
if [[ -f $GPKG ]]; then
  echo "  GPKG already exists, skipping."
else
  for j in $JSDIR/*.json
  do
    echo
    echo "  Converting $j to $GPKG layer"
    ogr2ogr -f GPKG -a_srs 'EPSG:4326' -update -overwrite -nln $(basename $j .json)  $GPKG $j
    ogrinfo $GPKG
  done
fi

echo "---> Converting to KML"
# Create KML versions of the JSONs
KMLDIR=${DDIR}/KML
mkdir -p $KMLDIR

for j in $JSDIR/*.json
do
  KMLF=$KMLDIR/$(basename $j .json).kml
  echo
  echo "  Converting $j to $KMLF "
  ogr2ogr -f KML $KMLF $j -mapFieldType DateTime=String
done

# Zip the KMLs to an archive
( cd $DDIR && zip -r kml.zip $(basename $KMLDIR) )

echo 
echo Outputs:
echo -------
echo GeoPackage with geozones:    $GPKG
echo ZIP archive with KML layers: $DDIR/kml.zip

