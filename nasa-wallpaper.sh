#!/bin/bash

# ********************************
# *** OPTIONS
# ********************************
# Set this to the directory you want pictures saved
PICTURES_DIR=~/Pictures/Wallpapers/
mkdir -p $PICTURES_DIR

# ********************************
# *** FUNCTIONS
# ********************************
get_page() {
    #    echo "Downloading page to find image"
    /usr/local/bin/wget http://apod.nasa.gov/apod/ --quiet -O /tmp/apod.html
    sed -n -e 's/.*IMG SRC="\(.*\)".*/http:\/\/apod.nasa.gov\/apod\/\1/p' /tmp/apod.html > /tmp/pic_url
}

clean_up() {
    # Clean up
    #    echo "Cleaning up temporary files"
    if [[ -e "/tmp/pic_url" ]]; then
        rm /tmp/pic_url
    fi
    
    if [[ -e "/tmp/apod.html" ]]; then
        rm /tmp/apod.html
    fi
}

# ********************************
# *** MAIN
# ********************************
# Set date
TODAY=$(date +'%Y%m%d')
changed=false

# If we don't have the image already today
if [[ ! -e $PICTURES_DIR/${TODAY}_apod.jpg ]]; then
    get_page
    # Got the link to the image
    PICURL=`/bin/cat /tmp/pic_url`
    # echo  "Picture URL is: ${PICURL}"
    # echo  "Downloading image"
    /usr/local/bin/wget --quiet $PICURL -O $PICTURES_DIR/${TODAY}_apod.jpg && changed=true
# Else if we have it already, check if it's the most updated copy
else
    get_page
    # Got the link to the image
    PICURL=`/bin/cat /tmp/pic_url`
    # echo  "Picture URL is: ${PICURL}"
    # Get the filesize
    SITEFILESIZE=$(/usr/local/bin/wget --spider $PICURL 2>&1 | grep Length | awk '{print $2}')
    FILEFILESIZE=$(stat -f %z $PICTURES_DIR/${TODAY}_apod.jpg)
    # If the picture has been updated
    if [[ $SITEFILESIZE != $FILEFILESIZE ]]; then
        # echo "The picture has been updated, getting updated copy"
        rm $PICTURES_DIR/${TODAY}_apod.jpg
        # Got the link to the image
        PICURL=`/bin/cat /tmp/pic_url`
        # echo  "Downloading image"
        /usr/local/bin/wget --quiet $PICURL -O $PICTURES_DIR/${TODAY}_apod.jpg && changed=true
    fi
fi

if $changed; then
    /usr/local/bin/desktoppr "$PICTURES_DIR/${TODAY}_apod.jpg"
fi

clean_up

