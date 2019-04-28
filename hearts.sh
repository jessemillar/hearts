#!/usr/bin/env bash

jq '.[.| length] |= . + {"date": "2010-01-07T19:55:99.999Z", "xml": "xml_samplesheet_2017_01_07_run_09.xml", "status": "OKKK", "message": "metadata loaded into iRODS successfullyyyyy"}' cards.json > test.json
rm cards.json
mv test.json cards.json
