# mplall

A command-line driven, playlist-building, media-looper (using a variety of engines).  Particularly well-suited for Raspberry Pi applications using `omxplayer` but certainly works for `mplayer` and all derivatives.  As `omxplayer` is able to hardware accelerate playback but cannot make playlists (even if it is deprecated), `mplall` is what you're looking for and continues to be updated.

A goal of `mplall` is that its users don't need to touch the script to achieve their desired results.  Please use `cd` and `mplall.sh` instead!

Use it to play music, watch videos, or for example pilot a video for informational or artistic purposes.  A playlist will be generated automatically from the working directory and loop.

## Functionality

Loops over media files, kind of like `cp -r *` if you could do `mplayer -r *`.  A low overhead, no-nonsense, single command to pilot mplayer, mplayer-x, mplayer2, and omxplayer.  I use it every day in regular Linux systems, Mac OS, and the Raspian distro for the Raspberry Pi.  I have also used it for running videos during outreach events (with zero configuration and excellent results).

Its normal defaults include looping forever, full screen video, with subtitles enabled, but these can be changed directly (or in a future configuration file).  The default is to make an alpha-numeric playlist (including files in subdirectories), but there are options for randomized playback as well as single-file input.

## How to 'install'

`mplall` is just a single shell script.  It doesn't do anything to your files nor your system.

You'll need at least one supported media player, which mplall looks for in this order:
* omxplayer (supports Raspberry Pi video hardware acceleration)
* mplayer-x (supports subtitles in macOS)
* mplayer2 (supports gapless audio)
* mplayer (default fallback)

Once you have a supported engine, download the script `mplall.sh`, put it somewhere in your PATH, run `chmod +x` on `mplall.sh`, change to any directory with media files, and give it a try!  

## Usage

`mplall` is a command-line interface program.  Firstly, please open a terminal emulator on a UNIX-like system.

In general, you can `cd` to any directory with media files and simply call `mplall.sh`.  In practice, for optimal usage, the media files are best organized by directories (e.g., Artist/Album/01_Song) and not a giant torrent dump with thousands of files in one directory.  `mplall` will give you a warning if you try to call it from your home directory (which could involve parsing thousands of filenames).  

It has a few kind of options, like randomization, single-file input, blackout on the Raspberry Pi, etc.  Call `mplall.sh` with any junk like `mplall.sh --help` and it will instruct you how it can be invoked.

`mplall` also displays some basic features of the script (or engine) relevant to quitting or seeking to a new track.  These may be obscured by video output. 

`Ctrl+c` will always kill `mplall`

## Features

Various options are implemented to randomize the playlist, blackout the desktop, minimize the terminal, etc.  

In 2024, profiles and continue watching are released for the RPi version.

See the help messaging below:

```
Recursively find and play media files starting from the present directory, forever.
Video is full-screened; subtitles enabled by default. 
Several media players are supported, including omxplayer for Raspberry Pi.

Usage $0: [-b] [-B] [-c] [-D] [-p int] [-M] [-R] [file]

options:
   -b           : black background outside video on RPi omxplayer
   -B           : black background outside video on any system, without flashing the desktop between tracks
                    Note: The GUI OSD for, e.g., volume control can be seen in -B but not -b mode.
   -c           : continues playing from previous occasion (presently only on RPi)
   -D           : play media on Desktop (experimental)
   -p [<int>]   : profile # environment (presently only on RPi.) To see profiles use -p list
   -M           : minimize the terminal, black background, without flashing the desktop between tracks
                    Note: The user needs to refocus to the terminal to control the media!
   -R           : generate Random playlist
arguments:
   file         : specific file to play (optional)
```

## History

`mplall` was originally a one-liner I wrote to listen to music without any overhead in 2007 during long Gentoo Linux installs.  I discovered later that it's also good for watching videos.  Although the playlists it can construct are limited, no work is needed by the user (principle of maximum laziness).  

In more recent years, I found that `omxplayer` is needed on the Raspberry Pi to watch most videos owing to its use of hardware acceleration.  However, `omxplayer` does not support playlists.  None of the scripts I could find online were satisfactory, so I spent time to workout a scripted playlist system to support `omxplayer` in `mplall`.  Based on these considerations, I thought there could be a wider audience interested in this script (considering the number of forum posts asking how to script `omxplayer`).

## Words of Warning

There are really none.  

The worst thing `mplall.sh` can probably do is be called from something like your home directory (to build its playlist, it needs to parse filenames).  It has a confirming mechanism to prevent this as an accident.

## Additional Raspberry Pi Notes

In the future, I will describe what I consider the optimal setup for Raspberry Pi using `mplall` to pilot `omxplayer`.

## Mac OS randomize bug

I only have access to a rather old MacBook, running 10.5.  The default `sort` doesn't understand -R for randomize.  Probably fink or macports already has a better version of `sort` we can use (which is probably installed on any system with mplayer-x).

## Disclaimer

If you are not satisfied, please let me know how I can help.  My goal is to provide a useful script that is simple and easy to use.  However, I code this script for myself and I share it for goodwill.  Whatever happens, happens, and it is not my fault.

There are no restrictions to the use of `mplall`, although ideally I like to be notified or credited.

Please see the licence for more details.
