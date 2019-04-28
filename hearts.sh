#!/usr/bin/env bash

# Set all variables to empties to allow for mandatory while loops below
NAME=
DESCRIPTION=
IMAGE=
HOMEPAGE=
DISTRIBUTOR=
ARTIST=
MANUFACTURER=
UPC=
NOTES=
OWNED=
CONDITION=
LIMITED_NUMBER=
LIMITED_TOTAL=

# Mandatory fields are wrapped in while loops
while [ -z ${NAME} ]; do
	read -p "Deck name: " -e NAME
done

# TODO Check the database for similar decks before adding to the array
read -p "Deck description: " -e DESCRIPTION
# TODO Download images provided via a URL
read -p "Deck image: " -e IMAGE
read -p "Deck homepage: " -e HOMEPAGE
read -p "Deck distributor: " -e DISTRIBUTOR
read -p "Deck artist: " -e ARTIST
read -p "Deck manufacturer: " -e MANUFACTURER
read -p "Deck UPC: " -e UPC
read -p "Notes: " -e NOTES
read -p "How many owned: " -i 1 -e OWNED
read -p "Deck condition: " -i 0 -e CONDITION
# TODO Ask if the deck is a limited edition
read -p "Limited edition total count: " -i 0 -e LIMITED_TOTAL
read -p "Limited edition number: " -i 0 -e LIMITED_NUMBER

# Write to file
jq --arg NAME "$NAME" --arg DESCRIPTION "$DESCRIPTION" --arg IMAGE "$IMAGE" --arg HOMEPAGE "$HOMEPAGE" --arg DISTRIBUTOR "$DISTRIBUTOR" --arg ARTIST "$ARTIST" --arg MANUFACTURER "$MANUFACTURER" --arg UPC "$UPC" --arg NOTES "$NOTES" --arg OWNED "$OWNED" --arg CONDITION $CONDITION --arg LIMITED_NUMBER $LIMITED_NUMBER --arg LIMITED_TOTAL $LIMITED_TOTAL '.[.| length] |= . + {"name": $NAME, "description": $DESCRIPTION, "image": $IMAGE, "homepage": $HOMEPAGE, "distributor": $DISTRIBUTOR, "artist": $ARTIST, "manufacturer": $MANUFACTURER, "upc": $UPC, "notes": $NOTES, "owned": $OWNED, "condition": $CONDITION, "limitedEdition": {"number": $LIMITED_NUMBER, "total": $LIMITED_TOTAL}}' cards.json > temp.json
mv -f temp.json cards.json
