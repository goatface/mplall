#!/bin/bash
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#  
# Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>
# 
# Everyone is permitted to copy and distribute verbatim or modified
# copies of this license document, and changing it is allowed as long
# as the name is changed.
#  
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
# 
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#
# Name: 	mplall.sh
# Does: 	loops media players on media files from the command line
# Systems: 	R Pi using hardware acceleration; GNU/Linux; MacOS
# Author: 	Copyright daid kahl 2019
# Last updated: 30 Dec 2019 21:04:38  	

VERSION=1.0

# Recognized media file types regex for grep (not case sensitive)
# You can add more, but please mimic the grep regex style employed
FILETYPES="(\.avi|\.flac|\.flv|\.mkv|\.mp3|\.mp4|\.m4a|\.mpeg|\.mpg|\.ogg|\.ogv|\.vob|\.wav|\.wmv)"

function Usage () {
cat <<-ENDOFMESSAGE

mplall version $VERSION

Recursively find and play media files starting from the present directory, forever.
Video is full-screened; subtitles enabled by default. 
Several media players are supported, including omxplayer for Raspberry Pi.

Usage $0: [-b] [-R] [-D] [file]

options:
   -b           : black background outside video on RPi omxplayer
   -D		: play media on Desktop (experimental)
   -R		: generate Random playlist
arguments:
   file		: specific file to play (optional)
ENDOFMESSAGE
    exit 1
}

#TODO: produce and employ defaults from file.  see getpaper

#TODO: 	catch PID of find to put on a control_c trap
# If we get a Ctrl+C, kill.  Needed for RPi but works in all cases
control_c () { 
  echo
  echo -e "\e[31;1mmplall received kill signal . . . quitting\e[0m\n"
  exit
}
# trap keyboard interrupt 
trap control_c SIGINT

#On Screen Display with instructions depending on the player
function OSD(){
  clear
  echo -e "\e[34;1;4mWelcome to mplall . . . the recursive command line media looper!\e[0m"
  if [[ $RPI ]];then
  	echo -e "\n\e[31;1mPress \e[34;1mCtrl+c \e[31mto kill $0 and \e[34;1mq \e[31mto seek to the next file.\e[0m\n" 
  else 
  	echo -e "\n\e[31;1mPress \e[34;1mCtrl+c \e[31mor \e[34;1mq \e[31mto kill $0 and the keys \e[34;1m< \e[31mor \e[34;1m> \e[31mto seek files in the playlist.\e[0m\n" 
  fi
}

# Set appropriate player or die
if ( which omxplayer &>/dev/null );then
	MPLAYER="omxplayer"
	RPI=true
elif ( which mplayer-x &>/dev/null );then
	MPLAYER="mplayer-x"
elif ( which mplayer2 &>/dev/null );then
	MPLAYER="mplayer2 --gapless-audio"
elif ( which mplayer &>/dev/null );then
	MPLAYER="mplayer"
	echo "gapless audio disabled, install mplayer2 to enable: http://www.mplayer2.org/"
else
        # TODO more web links or install suggestions
	printf "mplall requires omxplayer, mplayer-x, mplayer2 or mplayer, but none are in your PATH or not installed.\n\t(see http://www.mplayerhq.hu or http://www.mplayer2.org/)\nAborting.\n" >&2; exit 1; 
fi

# Option definition and parsing
Rflag=""
Dflag=""
bflag=""
while getopts 'bRD' OPTION
do
  case $OPTION in
  b)    bflag=1
        BLACKOUT="-b";;
  R)    Rflag=1
        RANDOMIZE="-R";;
  D)    Dflag=1
        which xwininfo &>/dev/null || { printf "mplall requires xwininfo for Desktop mode but it's not in your PATH or not installed.\n\t(see http://xorg.freedesktop.org/ )\nAborting.\n" >&2; exit 1; } 
        DESKTOPID=$(xwininfo -name Desktop | grep Desktop | awk '{printf $4}')
	WID="-wid $DESKTOPID"
	;;
  *)    Usage ;;
  esac
done
shift $((OPTIND-1))

if [[ ! -z "$2" ]];then
  echo "More than one manual input presently unsupported..."
  echo "Ignoring inputs after $1 "
fi

if [[ ! -z "$1" ]];then
  PLAYLIST="$PWD/$1"
  #TODO: pass multiple manual inputs
  #PLAYLIST="$@"
fi

if [[ "$PWD" = "$HOME" && -z "$PLAYLIST" ]];then
read -p  "Really recursively search all files for media in $HOME? (y/n): " -n 1 -r
echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    continue
  else
    exit
  fi
fi

if [ "$Rflag" ];then
	echo "mplall generating random playlist..."
	# TODO: Randomize manually inputted playlist.
  	#PLAYLIST=$(echo "$@"|sed 's/\ /\n/g'|sort $RANDOMIZE)
fi

if [[ $RPI ]];then # For omxplayer on Raspberry Pi, we need to pass files one-by-one to emulate a playlist
	# -o also is for the audio to use ALSA (usually the standard one for normal volume controls)
	OPTIONS="$BLACKOUT -o alsa"
	if [[ -z "$PLAYLIST" ]]; then
	  PLAYLIST="/tmp/.mplall"
	  # Populate playlist from working directory
	  find -L "$PWD" -type f | egrep -i "$FILETYPES" | sort $RANDOMIZE > $PLAYLIST
	else
	  echo "$PLAYLIST" > /tmp/.mplall
	  PLAYLIST="/tmp/.mplall"
	fi

	while true; do
	  # allow loop body to read stdin so redirect on 10, 
	  # see https://stackoverflow.com/questions/1521462/looping-through-the-content-of-a-file-in-bash
	  while read -u 10 entry; do
	    OSD 
	    echo -e "\e[34;1mPlaying \e[93;1m$entry \e[34;1m. . .\e[0m\n"
	    "$MPLAYER" $OPTIONS "$entry" 
	  done 10< "$PLAYLIST"
	done
else # For mplayer and derivatives, direct playlists are supported greatly simplifying the code
	OSD 
	if [[ -z "$PLAYLIST" ]];then
	  PLAYLIST=$(find -L "$PWD" -type f | egrep -i "$FILETYPES" |  sort $RANDOMIZE )
	  #PLAYLIST=$(find -L "$PWD" -type f | egrep -i '(\.avi|\.flac|\.flv|\.mkv|\.mp3|\.mp4|\.mpeg|\.mpg|\.ogg|\.ogv|\.vob|\.x|\.wav|\.wmv)' |  sort $RANDOMIZE )
	fi 
	$MPLAYER $WID -fs -loop 0 -zoom -playlist <(echo "$PLAYLIST")
fi

exit

# old
#$MPLAYER $WID -fs -loop 0 -zoom -playlist <(find -L "$PWD" -type f | egrep -i '(\.avi|\.flac|\.flv|\.mkv|\.mp3|\.mp4|\.m4a|\.mpeg|\.mpg|\.ogg|\.ogv|\.vob|\.wav|\.wmv)' | sort $RANDOMIZE )
#$MPLAYER -wid 0x1000003 -fs -loop 0 -zoom -playlist <(find -L "$PWD" -type f | egrep -i '(\.avi|\.flac|\.flv|\.mkv|\.mp3|\.mp4|\.mpeg|\.mpg|\.ogg|\.ogv|\.vob|\.wav|\.wmv)' | sort $* )

