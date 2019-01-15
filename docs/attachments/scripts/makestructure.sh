#!/bin/bash

set -eu

echo "${HOME}"

group="umcg-testgroup"
tmpName="tmpTest01"
base="${HOME}/groups/${group}/${tmpName}"

printf "creating directory structure"
mkdir -p "${base}/generatedscripts/"
mkdir -p "${base}/Samplesheets/"
mkdir -p "${base}/runs/"
mkdir -p "${base}/logs/"
mkdir -p "${base}/tmp/"

