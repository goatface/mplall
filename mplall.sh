#!/bin/bash
#            DO WHATEVER YOU WANT TO PUBLIC LICENSE
#  
# Everyone is permitted to copy and distribute verbatim or modified
# copies of this license document, and changing it is allowed as long
# as the name is changed.
#  
#            DO WHATEVER YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
# 
#  0. You just DO WHATEVER YOU WANT TO.
#
# Name: 	mplall.sh
# Does: 	loops media players on media files from the command line
# Systems: 	RPi using hardware acceleration; GNU/Linux; MacOS
# Author: 	daid kahl Copyright 2022
# Last updated: 14 Jan 2021 16:39:32  

VERSION=1.2

# RPI users: Set the audio device
# See man omxplayer under -o for valid audio output devices
# Here we default to ALSA, but options include: hdmi/local/both/alsa
# Without anything, omxplayer may not respond to standard system volume controls
RPIAUDIO="alsa"
#RPIAUDIO="hdmi"

# Recognized media file types regex for grep (not case sensitive)
# You can add more, but please mimic the grep regex style employed
FILETYPES="(\.avi|\.flac|\.flv|\.mkv|\.mp3|\.mp4|\.m4a|\.mpeg|\.mpg|\.ogg|\.ogv|\.vob|\.wav|\.wmv)"

function Usage () {
cat <<-ENDOFMESSAGE

mplall version $VERSION

Recursively find and play media files starting from the present directory, forever.
Video is full-screened; subtitles enabled by default. 
Several media players are supported, including omxplayer for Raspberry Pi.

Usage $0: [-b] [-B] [-M] [-R] [-D] [file]

options:
   -b           : black background outside video on RPi omxplayer
   -B           : black background outside video on any system, without flashing the desktop between tracks
                    Note: The GUI OSD for, e.g., volume control can be seen in -B but not -b mode.
   -M           : minimize the terminal, black background, without flashing the desktop between tracks
                    Note: The user needs to refocus to the terminal to control the media!
   -D		: play media on Desktop (experimental)
   -R		: generate Random playlist
arguments:
   file		: specific file to play (optional)
ENDOFMESSAGE
    exit 1
}

#TODO: produce and employ defaults from file.  see getpaper
#TODO: fix mplall grep to have 4 at end ... it tried to play blah.mkv.jpg ....!
#	see, e.g., https://unix.stackexchange.com/questions/163481/a-command-to-print-only-last-3-characters-of-a-string/163491

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

# generation of playlist for omxplayer on RPi
function RPIPLAYLIST(){
  # Populate playlist from working directory
  find -L "$PWD" -type f | egrep -i "$FILETYPES" | sort $RANDOMIZE > $PLAYLIST
}

## Blackout hacking
#function BLACKOUTHAX(){
#  # create a 1x1 black pixel on the fly  
#  CANVAS=/tmp/.mplall_canvas.gif
#  convert -size 1x1 canvas:black $CANVAS
#}

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
Bflag=""
Mflag=""
while getopts 'bBDMR' OPTION
do
  case $OPTION in
  b)    bflag=1
        BLACKOUT="-b"
	if [[ !$RPI ]];then
          echo "Warning: -b mode only works on RPi's omxplayer.  Ignoring -b.  Try -B instead."
	fi
	;;
  B)    Bflag=1
        which wmctrl &>/dev/null || { printf "mplall requires wmctrl for Blackout hacked mode but it's not in your PATH or not installed.\nAborting.\n" >&2; exit 1; } 
        which feh &>/dev/null || { printf "mplall requires feh for Blackout hacked mode but it's not in your PATH or not installed.\nAborting.\n" >&2; exit 1; } 
        which convert &>/dev/null || { printf "mplall requires imagemagick for Blackout hacked mode but it's not in your PATH or not installed.\nAborting.\n" >&2; exit 1; } 
	;;
  M)    Mflag=1
        MINIMIZE="-M"
        which xdotool &>/dev/null || { printf "mplall requires xdotool for Minimize mode but it's not in your PATH or not installed.\nAborting.\n" >&2; exit 1; } 
        #which feh &>/dev/null || { printf "mplall requires feh for Minimize mode but it's not in your PATH or not installed.\nAborting.\n" >&2; exit 1; } 
        #which convert &>/dev/null || { printf "mplall requires imagemagick for Minimize mode but it's not in your PATH or not installed.\nAborting.\n" >&2; exit 1; } 
	;;
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

if [[ $Bflag ]];then
  # create a 1x1 black pixel on the fly  
  CANVAS=/tmp/.mplall_canvas.gif
  convert -size 1x1 canvas:black $CANVAS
  # full screen the black pixel with feh and return the focus to the terminal
  wmctrl -T mplall$$ -r :ACTIVE: ; feh -F $CANVAS & sleep 0.1 ; wmctrl -a mplall$$
fi

if [[ $Mflag ]];then
  # minimize the terminal
  xdotool windowminimize $(xdotool getactivewindow)
fi

if [[ $RPI ]];then # For omxplayer on Raspberry Pi, we need to pass files one-by-one to emulate a playlist
	OPTIONS="$BLACKOUT -o $RPIAUDIO"
	if [[ -z "$PLAYLIST" ]]; then
	  PLAYLIST="/tmp/.mplall"
	  RPIPLGEN=1
	  RPIPLAYLIST 
	else
	  echo "$PLAYLIST" > /tmp/.mplall
	  RPIPLGEN=""
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
	  # regenerate playlist to reflect any new files.  
	  # see https://github.com/goatface/mplall/issues/1
	  if [ "$RPIPLGEN" ];then
	    RPIPLAYLIST
	  fi
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

