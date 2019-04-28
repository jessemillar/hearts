#!/usr/bin/env bash

# Remove a lingering temp file from a previous bad run
[[ -f temp.json ]] && rm temp.json

# Set non-defaulting variables to empties to allow for mandatory while loops below
NAME=
DESCRIPTION=
IMAGE=
HOMEPAGE=
DISTRIBUTOR=
ARTIST=
MANUFACTURER=
UPC=
NOTES=
OWNED=1
CONDITION=0
LIMITED_NUMBER=0
LIMITED_TOTAL=0

# Mandatory fields are wrapped in while loops
while [ -z ${NAME} ]; do
	read -p "Deck name: " -e NAME
done

# TODO Check the database for similar decks before adding to the array
read -p "Deck description: " -e DESCRIPTION

read -p "Deck image: " -e IMAGE
# Download images provided via a URL
if [[ $IMAGE =~ ^https?:\/\/.+ ]]; then
	mkdir tmp
	cd tmp
	curl -JLO $IMAGE
	TMP_FILENAME=$(ls | head -n 1)
	FINAL_NAME=${NAME// /-}.png
	FINAL_NAME_LOWERCASE=$(echo "$FINAL_NAME" | awk '{print tolower($0)}')
	convert "$TMP_FILENAME" $FINAL_NAME
	mv $FINAL_NAME ../images/$FINAL_NAME_LOWERCASE
	IMAGE=$FINAL_NAME_LOWERCASE
	cd ..
	rm -rf tmp
fi
IMAGE=images/$IMAGE

read -p "Deck homepage: " -e HOMEPAGE
read -p "Deck distributor: " -e DISTRIBUTOR
read -p "Deck artist: " -e ARTIST
read -p "Deck manufacturer: " -e MANUFACTURER
read -p "Deck UPC: " -e UPC
read -p "Notes: " -e NOTES
read -p "How many owned: [1] " -e OWNED
read -p "Deck condition: [0] " -e CONDITION

read -p "Is deck part of a limited release? [y/N] " -e LIMITED
# TODO Make this work
if [ "$LIMITED" = "y" ]; then
	while [ $LIMITED_TOTAL = 0 ]; do
		read -p "Limited edition total count: " -e LIMITED_TOTAL
	done

	while [ $LIMITED_NUMBER = 0 ]; do
		read -p "Limited edition number: " -e LIMITED_NUMBER
	done
fi

# Write to file
jq --arg NAME "$NAME" --arg DESCRIPTION "$DESCRIPTION" --arg IMAGE "$IMAGE" --arg HOMEPAGE "$HOMEPAGE" --arg DISTRIBUTOR "$DISTRIBUTOR" --arg ARTIST "$ARTIST" --arg MANUFACTURER "$MANUFACTURER" --arg UPC "$UPC" --arg NOTES "$NOTES" --arg OWNED $OWNED --arg CONDITION $CONDITION --arg LIMITED_NUMBER $LIMITED_NUMBER --arg LIMITED_TOTAL $LIMITED_TOTAL '.[.| length] |= . + {"name": $NAME, "description": $DESCRIPTION, "image": $IMAGE, "homepage": $HOMEPAGE, "distributor": $DISTRIBUTOR, "artist": $ARTIST, "manufacturer": $MANUFACTURER, "upc": $UPC, "notes": $NOTES, "owned": $OWNED, "condition": $CONDITION, "limitedEdition": {"number": $LIMITED_NUMBER, "total": $LIMITED_TOTAL}}' cards.json > temp.json && mv -f temp.json cards.json
