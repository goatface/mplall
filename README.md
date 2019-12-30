# mplall

Command-line driven media looper, using a variety of engines.  Particularly well-suited for Raspberry Pi applications using `omxplayer`.

Use it to play music, watch videos, or for example pilot a video for informational purposes.

## Functionality

Loops over media files, kind of like `cp -r *` if you could do `mplayer -r *`.  A low overhead, no-nonsense, single command to pilot mplayer, mplayer-x, mplayer2, and omxplayer.  I use it every day in regular Linux systems, Mac OS, and the Raspian distro for the Raspberry Pi.  I have also used it for running videos during outreach events (with zero configuration and excellent results).

Its normal defaults include looping forever, full screen video, with subtitles enabled, but these can be changed in a future configuration file.  The default is to make an alphabetic playlist (including files in subdirectories), but there is are options for randomized playback as well as single-file input.

## How to 'install'

`mplall` is just a single shell script.  While it needs a run configuration file, it will initialize one for you the first time you run it.  You'll need at least one supported media player:
* omxplayer
* mplayer-x
* mplayer
* mplayer2

So you can download the script `mplall.sh`, put it somewhere in your PATH, run `chmod +x` on `mplall.sh`, change to any directory with media files, and give it a try!


## Usage

In general, you can move to any directory with media files and simply call `mplall.sh`.  In practice, for optimal usage, the media files are best organized by directories (e.g., Album/Arist/01. Song) and not a giant torrent dump with thousands of files in one directory.  `mplall` will give you a warning if you try to call it from your home directory (which could involve parsing thousands of files).  

## History

`mplall` was originally a one-liner I used mainly for listening to music without any overhead.  It's also good for watching videos, and although the playlists it can construct are limited, no work is needed by the user (principle of maximum laziness).  

In more recent years, I found that `omxplayer` is needed on the Raspberry Pi to watch most videos owing to its use of hardware acceleration.  However, `omxplayer` has a very primitive command-line interface and does not even support playlists.  None of the scripts I could find online were satisfactory, so I spent time to workout a scripted playlist system to support `omxplayer` in `mplall`.  Based on these considerations, I considered there could be a wider audience interested in this script (considering the number of forum posts asking how to script `omxplayer`).

## Additional Raspberry Pi Notes

In the future, I willl describe what I consider the optimal setup for Raspberry Pi using `mplall` to pilot `omxplayer`.

