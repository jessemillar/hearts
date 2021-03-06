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
	read -rp "Deck name: " -e NAME
	# Trim whitespace
	NAME=$(echo "$NAME" | awk '{$1=$1};1')
done

### Optional deck color
read -rp "Deck style/color: " -e STYLE
if [ -n "$STYLE" ]; then
	NAME="$NAME - $STYLE"
fi

# Check the database for similar decks before adding to the array
SEARCH_RESULTS=$(cat decks.json | jq --arg NAME "$NAME" '.[] | select(.name|test($NAME)) | .name')
if [ -n "$SEARCH_RESULTS" ]; then
	echo "A deck named '$NAME' already exists in decks.json"
	exit 1
fi

### Deck image
read -rp "Deck image: " -e IMAGE
IMAGE=$(echo "$IMAGE" | awk '{$1=$1};1')

# Download images provided via a URL
if [[ $IMAGE =~ ^https?:\/\/.+ ]]; then
	mkdir tmp
	cd tmp || exit 1
	curl -JLO "$IMAGE" --silent
	TMP_FILENAME=$(ls | head -n 1)
	FINAL_NAME=${NAME// /-}.png
	FINAL_NAME_LOWERCASE=$(echo "$FINAL_NAME" | awk '{print tolower($0)}')
	convert "$TMP_FILENAME" "$FINAL_NAME"
	mv "$FINAL_NAME" ../images/"$FINAL_NAME_LOWERCASE"
	# Make a preview image
	cp ../images/"$FINAL_NAME_LOWERCASE" ../images/previews/"$FINAL_NAME_LOWERCASE"
	mogrify -resize 100 ../images/previews/"$FINAL_NAME_LOWERCASE"
	IMAGE=$FINAL_NAME_LOWERCASE
	cd ..
	rm -rf tmp
fi
IMAGE=images/$IMAGE

### Deck homepage
read -rp "Deck homepage: " -e HOMEPAGE

### Deck description
read -rp "Deck description: " -e DESCRIPTION
# Trim whitespace
DESCRIPTION=$(echo "$DESCRIPTION" | awk '{$1=$1};1')

### Deck distributor
echo "Deck distributor:"
DISTRIBUTOR_OPTIONS=("Art of Play" "theory11" "Dan and Dave" "DeckStarter" "Kickstarter" "Bicycle" "Ellusionist" "Unknown" "Custom")
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
			"Dan and Dave")
					DISTRIBUTOR="Dan and Dave"
					break
					;;
			"DeckStarter")
					DISTRIBUTOR="DeckStarter"
					break
					;;
			"Kickstarter")
					DISTRIBUTOR="Kickstarter"
					break
					;;
			"Bicycle")
					DISTRIBUTOR="Bicycle"
					break
					;;
			"Ellusionist")
				  DISTRIBUTOR="Ellusionist"
					break
					;;
			"Unknown")
					DISTRIBUTOR=""
					break
					;;
			"Custom")
					while [ -z "$DISTRIBUTOR" ]; do
						read -rp "Custom distributor: " -e DISTRIBUTOR
					done
					break
					;;
			*) echo "Invalid option $REPLY";;
	esac
done

### Deck artist
read -rp "Deck artist: " -e ARTIST
ARTIST=$(echo "$ARTIST" | awk '{$1=$1};1')

### Deck manufacturer
echo "Deck manufacturer:"
MANUFACTURER_OPTIONS=("Art of Play" "theory11" "Dan and Dave" "DeckStarter" "United States Playing Card Company" "Ellusionist" "Unknown" "Custom")
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
			"Dan and Dave")
					MANUFACTURER="Dan and Dave"
					break
					;;
			"DeckStarter")
					MANUFACTURER="DeckStarter"
					break
					;;
			"United States Playing Card Company")
					MANUFACTURER="United States Playing Card Company"
					break
					;;
			"Ellusionist")
				  MANUFACTURER="Ellusionist"
					break
					;;
			"Unknown")
					MANUFACTURER=""
					break
					;;
			"Custom")
					while [ -z "$MANUFACTURER" ]; do
						read -rp "Custom manufacturer: " -e MANUFACTURER
					done
					break
					;;
			*) echo "Invalid option $REPLY";;
	esac
done


read -rp "Deck UPC: " -e UPC

## Deck notes
read -rp "Notes: " -e NOTES
NOTES=$(echo "$NOTES" | awk '{$1=$1};1')

### How many owned
read -rp "How many owned: [1] " -e OWNED
OWNED=${OWNED:-1}

### Deck condition
echo "Deck condition (for the majority of decks owned or the latest purchase):"
CONDITION_OPTIONS=("Sealed" "Opened" "Used" "Destroyed")
select OPTION in "${CONDITION_OPTIONS[@]}"; do
	CONDITION=$OPTION
	break
done

### Limited release decks
read -rp "Is deck part of a limited release? [y/N] " -e LIMITED
if [ "$LIMITED" == y ]; then
	while [ $LIMITED_TOTAL = 0 ]; do
		read -rp "Limited edition total count: " -e LIMITED_TOTAL
	done

	while [ $LIMITED_NUMBER = 0 ]; do
		read -rp "Limited edition number: " -e LIMITED_NUMBER
	done
fi

# Write to file
jq --arg NAME "$NAME" --arg DESCRIPTION "$DESCRIPTION" --arg IMAGE "$IMAGE" --arg HOMEPAGE "$HOMEPAGE" --arg DISTRIBUTOR "$DISTRIBUTOR" --arg ARTIST "$ARTIST" --arg MANUFACTURER "$MANUFACTURER" --arg UPC "$UPC" --arg NOTES "$NOTES" --arg OWNED "$OWNED" --arg CONDITION "$CONDITION" --arg LIMITED_NUMBER "$LIMITED_NUMBER" --arg LIMITED_TOTAL "$LIMITED_TOTAL" '.[.| length] |= . + {"name": $NAME, "description": $DESCRIPTION, "image": $IMAGE, "homepage": $HOMEPAGE, "distributor": $DISTRIBUTOR, "artist": $ARTIST, "manufacturer": $MANUFACTURER, "upc": $UPC, "notes": $NOTES, "owned": $OWNED, "condition": $CONDITION, "limitedEdition": {"number": $LIMITED_NUMBER, "total": $LIMITED_TOTAL}}' decks.json > temp.json && mv -f temp.json decks.json

# Push the update to GitHub
git add -A && git commit -m "Adding the $NAME deck" && git push
