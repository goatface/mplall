# mplall

Command-line driven media looper, using a variety of engines.  Particularly well-suited for Raspberry Pi applications.

Use it to play music, watch videos, or for example pilot a video for informational purposes.

## Functionality

Loops over media files, kind of like `cp -r *` if you could do `mplayer -r *`.  A low overhead, no-nonsense, single command to pilot mplayer, mplayer-x, mplayer2, and omxplayer.  I use it every day in regular Linux systems, Mac OS, and the Raspian distro for the Raspberry Pi.  I have also used it for running videos during outreach events (with zero configuration and excellent results).

Its normal defaults include looping forever, full screen video, with subtitles enabled, but these can be changed in a configuration file.  The default is to make an alphabetic playlist (including files in subdirectories), but there is are options for randomized playback as well as single-file input.

## How to 'install'

`mplall` is just a single shell script.  While it needs a run configuration file, it will initialize one for you the first time you run it.  You'll need at least one supported media player:
* omxplayer
* mplayer-x
* mplayer
* mplayer2

So you can download the file, put it somewhere in your PATH, run `chmod +x` on `mplall.sh`, move to a directory with media files, and give it a try!


## Usage

In general, you can move to any directory with media files and simply call `mplall.sh`.  In practice, for optimal usage, the media files are best organized by directories (e.g., Album/Arist/01. Song) and not a giant torrent dump with thousands of files in one directory.  `mplall` will give you a warning if you try to call it from your home directory (which could involve parsing thousands of files).  

## History

`mplall` was originally a one-liner I used mainly for listening to music without any overhead.  It's also good for watching videos, and although the playlists it can construct are limited, no work is needed by the user (principle of maximum laziness).  

In more recent years, I found that `omxplayer` is needed on the Raspberry Pi to watch most videos owing to its use of hardware acceleration.  However, `omxplayer` has a very primitive command-line interface and does not even support playlists.  None of the scripts I could find online were satisfactory, so I spent time to workout a scripted playlist system to support `omxplayer` in `mplall`.  Based on these considerations, I considered there could be a wider audience interested in this script (considering the number of forum posts asking how to script `omxplayer`).

## Additional Raspberry Pi Notes

Here I describe what I consider the optimal setup for Raspberry Pi using `mplall` to pilot `omxplayer`.


Download, add bibtex, query bibtex, strip propaganda, print, and/or open papers based on reference!

Here, _papers_ are academic journal articles, usually somehow related to nuclear astrophysics, which is my interest.  It mainly relies on the [SAO/NASA Astrophysics Data System (ADS)](http://adsabs.harvard.edu/) and would typically take queries following the Journal/Volume/Page format.  In a full blown operation, here is what happens: 
* You feed `getpaper` some options, including a journal name, a volume, and a page number
* `getpaper` checks if ADS has a matching query (and if there are multiple returns, prompts you to choose one)
* `getpaper` checks if you have a matching bibkey in your library.bib file, so as not to duplicate
* `getpaper` checks the expected output PDF file name, so as not to download for no reason
* If it was instructed to open the paper, it would open the paper you already had but forgot you downloaded
* Finding that you do not have this paper, it will generate a full bibtex entry, including the abstract
* `getpaper` will download the paper (if you have subscription access)
* `getpaper` can let you handle captchas at APS
* `getpaper` will ensure that what was downloaded looks like a legitimate PDF and not rubbish
* `getpaper` will strip the first page of the PDF if it's nonsense about the online journal with your IP address
* `getpaper` will link the downloaded location of the paper into the bibtex entry
* `getpaper` will create a sensible directory structure like articles/2013 to place the paper if needed
* `getpaper` will open the paper if you asked it to
* `getpaper` will print the paper if you asked it to (please have an idea of the page length first!)

If you didn't have subscription access, perhaps because you are at home or travelling...
* `getpaper` can accept an SSH user and host to a machine at your work, and use that server to transparently download and transfer the paper to your local machine (though you should set up passwordless SSH and ensure your work machine has the right tools).  However, I have been unable to test or bugcheck this option for several years owing to firewalls.  Thus you can expect particularly APS journals would not work at the very least.

**And it will do all that, with a simple, single command.**  That could save you at least sixty seconds doing it yourself!

What it will **not** do:
* Harvest papers blindly.  You need to feed it the relevant Journal/Volume/Page information yourself.  This is to comply with the online journals' TOS.  It keeps you from clicking the mouse, not from never connecting to the internet ever again by downloading the Library of Alexandria.

You probably want to be using [JabRef](http://jabref.sourceforge.net/) to manage your library.bib file.  It's awesome...

## How to 'install'

`getpaper` is just a single shell script.  While it needs a run configuration file, it will initialize one for you the first time you run it.  Many of the features are possible owing to lovely free software.  Although `getpaper` checks for the dependencies it requires itself, here is a list with a brief description:

* [lynx](https://lynx.browser.org/): A scriptable, command-line driven web browser.  This must be compiled with the enable-externs option.
* [wget](http://www.gnu.org/software/wget/): A non-interactive downloading tool.
* [pdfinfo](https://poppler.freedesktop.org/): Part of poppler or xpdf, `getpaper` uses this to validate a download as being a pdf.
* [pdftk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/): PDF Toolkit, used to remove any propaganda pages.
* [imagemagick](https://www.imagemagick.org): A versatile image tool, it is used for the APS Captcha rendering.
* [zenity](https://help.gnome.org/users/zenity/stable/): A pop-up tool handy for simple GUIs in shell scripts.

It also requires the common system tools: [grep](https://www.gnu.org/software/grep/), [sed](https://www.gnu.org/software/grep/), and [awk](https://www.gnu.org/software/gawk/).
