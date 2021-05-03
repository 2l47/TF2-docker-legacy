#!/usr/bin/env bash

# Just download the maps, the configure script installs them
mkdir rgl_maps
wget -i rgl-map-urls.txt --content-disposition --directory-prefix rgl_maps --no-clobber
