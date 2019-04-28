#!/usr/bin/env bash

# Remove a lingering temp file from a previous bad run
[[ -f temp.json ]] && rm temp.json

# Set non-defaulting variables to empties to allow for mandatory while loops below
NAME=
STYLE=
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

### Deck name
# Mandatory fields are wrapped in while loops
while [ -z "$NAME" ]; do
	# TODO Check the database for similar decks before adding to the array
	read -p "Deck name: " -e NAME
	# Trim whitespace
	NAME=$(echo $NAME | awk '{$1=$1};1')
done

### Optional deck color
read -p "Deck style/color: " -e STYLE
if [ ! -z ${STYLE} ]; then
	NAME="$NAME - $STYLE"
fi

### Deck image
while [ -z ${IMAGE} ]; do
	read -p "Deck image: " -e IMAGE
	IMAGE=$(echo $IMAGE | awk '{$1=$1};1')
done

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

### Deck description
read -p "Deck description: " -e DESCRIPTION
# Trim whitespace
DESCRIPTION=$(echo $DESCRIPTION | awk '{$1=$1};1')

read -p "Deck homepage: " -e HOMEPAGE

### Deck distributor
echo "Deck distributor:"
DISTRIBUTOR_OPTIONS=("Art of Play" "theory11" "Unknown" "Custom")
select OPTION in "${DISTRIBUTOR_OPTIONS[@]}"
do
	case $OPTION in
			"Art of Play")
					DISTRIBUTOR="Art of Play"
					break
					;;
			"theory11")
					DISTRIBUTOR="theory11"
					break
					;;
			"Unknown")
					DISTRIBUTOR=""
					break
					;;
			"Custom")
					while [ -z ${DISTRIBUTOR} ]; do
						read -p "Custom distributor: " -e DISTRIBUTOR
					done
					break
					;;
			*) echo "Invalid option $REPLY";;
	esac
done

### Deck artist
read -p "Deck artist: " -e ARTIST
ARTIST=$(echo $ARTIST | awk '{$1=$1};1')

### Deck manufacturer
echo "Deck manufacturer:"
MANUFACTURER_OPTIONS=("Art of Play" "theory11" "United States Playing Card Company" "Unknown" "Custom")
select OPTION in "${MANUFACTURER_OPTIONS[@]}"
do
	case $OPTION in
			"Art of Play")
					MANUFACTURER="Art of Play"
					break
					;;
			"theory11")
					MANUFACTURER="theory11"
					break
					;;
			"United States Playing Card Company")
					MANUFACTURER="United States Playing Card Company"
					break
					;;
			"Unknown")
					MANUFACTURER=""
					break
					;;
			"Custom")
					while [ -z ${MANUFACTURER} ]; do
						read -p "Custom manufacturer: " -e MANUFACTURER
					done
					break
					;;
			*) echo "Invalid option $REPLY";;
	esac
done


read -p "Deck UPC: " -e UPC

## Deck notes
read -p "Notes: " -e NOTES
NOTES=$(echo $NOTES | awk '{$1=$1};1')

read -p "How many owned: [1] " -e OWNED

### Deck condition
echo "Deck condition (for the majority of decks owned or the latest purchase):"
CONDITION_OPTIONS=("Sealed" "Opened" "Used" "Destroyed")
select OPTION in "${CONDITION_OPTIONS[@]}"; do
	CONDITION=$OPTION
	break
done

### Limited release decks
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
jq --arg NAME "$NAME" --arg DESCRIPTION "$DESCRIPTION" --arg IMAGE "$IMAGE" --arg HOMEPAGE "$HOMEPAGE" --arg DISTRIBUTOR "$DISTRIBUTOR" --arg ARTIST "$ARTIST" --arg MANUFACTURER "$MANUFACTURER" --arg UPC "$UPC" --arg NOTES "$NOTES" --arg OWNED "$OWNED" --arg CONDITION "$CONDITION" --arg LIMITED_NUMBER "$LIMITED_NUMBER" --arg LIMITED_TOTAL "$LIMITED_TOTAL" '.[.| length] |= . + {"name": $NAME, "description": $DESCRIPTION, "image": $IMAGE, "homepage": $HOMEPAGE, "distributor": $DISTRIBUTOR, "artist": $ARTIST, "manufacturer": $MANUFACTURER, "upc": $UPC, "notes": $NOTES, "owned": $OWNED, "condition": $CONDITION, "limitedEdition": {"number": $LIMITED_NUMBER, "total": $LIMITED_TOTAL}}' decks.json > temp.json && mv -f temp.json decks.json

# Push the update to GitHub
git add -A && git commit -m "Adding the $NAME deck" && git push
