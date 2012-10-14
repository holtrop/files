#!/bin/sh

vobcopy -I -i /dev/dvd

echo " ****"
echo "Enter the name"
read name

echo " ****"
echo "Enter title number"
read title

mencoder dvd://"$title" -ovc lavc -af volnorm=1 \
    -alang en -oac mp3lame -lameopts cbr:preset=128 \
    -lavcopts threads=4:vbitrate=1200:v4mv:vhq:vcodec=mpeg4 -vf \
    pp=de,scale=720:-2 -nosub -o "$name.mpg"
