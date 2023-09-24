Moto X4 XT1900-1 stock ROM install
==================================

NAME
----

install.sh - flash stock firmware to XT1900-1, likely a Google Fi Moto X4 phone

SYNOPSIS
--------

install.sh [-n]

DESCRIPTION
-----------

install.sh is a script that will attempt to download, verify, and install the
latest available stock ROM with Android 9 firmware for a Google Fi Moto X4
phone (XT1900-1).  The firmware is flashed using an adapted flash-all.sh script
referenced in an XDA developers forum post by munchy_cool
(<https://forum.xda-developers.com/t/guide-video-text-how-to-flash-official-factory-firmware-moto-x4.3808348/>).
The only change in the flash-all.sh script is to call fastboot from the PATH
rather than the current working directory.

The script is considered a "bundled" script that assumes that the directory it
is run from is writable, and so it will attempt to guess which directory it
resides in and will change to its directory.  Non-bundled uses are not
intended.

The download will attempt to download from the lolinet backup mirror,
<https://mirrors-obs-2.lolinet.com/>, and will verify against a SHA256 sum for
integrity.

This script may break in the future when the mirror scrubs old files.  If you
can, keep a copy of the stock ROM image.

This script is only tested against XT1900-1.  The script may be adapted for
other Moto X4 ROMs, but no guarantees.

The files the script creates and downloads are documented in the FILES section.

This script should suffice to set up the device for LineageOS installation, as
mentioned in one of the warnings on the LineageOS install instructions
<https://wiki.lineageos.org/devices/payton/install>.

OPTIONS
-------

-n, --dry-run
    Perform a dry run of the script.  All commands that run external programs
    will only print the status.  It is mostly okay for development on the
    script with various manually set up filesystem states.

EXIT STATUS
-----------

0   Successful program execution.

non-zero    Unsuccessful program execution.

FILES
-----

XT1900-1_PAYTON_FI_9.0_PPWS29.69-39-6-13_subsidy-DEFAULT_regulatory-DEFAULT_CFC.xml.zip
    The stock Google Fi ROM for Android 9 firmware.

XT1900-1_PAYTON_FI_9.0_PPWS29.69-39-6-13_subsidy-DEFAULT_regulatory-DEFAULT_CFC.xml.zip.sha256sum
    This is created to verify the SHA256 sum with `sha256sum -c`.

XT1900-1_PAYTON_FI_9.0_PPWS29.69-39-6-13_subsidy-DEFAULT_regulatory-DEFAULT_CFC.xml.zip.d/
    This directory is created to unzip the stock ROM into.  This is created
    with the .d suffix to avoid confusion with the fact it would have had the
    .xml extension.

XT1900-1_PAYTON_FI_9.0_PPWS29.69-39-6-13_subsidy-DEFAULT_regulatory-DEFAULT_CFC.xml.zip.d/PAYTON_FI_PPWS29.69-39-6-13_subsidy-DEFAULT_regulatory-DEFAULT_CFC.info.txt
    This file's existence is used to detect if the directory was unzipped
    properly.  On the author's system, it is the last file extracted, and so is
    a kludgey signifier of correct extraction.

BUGS
----

They are surprise features.

SEE ALSO
--------

https://wiki.lineageos.org/devices/payton/
    LineageOS Moto X4 wiki info.

https://wiki.lineageos.org/devices/payton/install
    LineageOS Moto X4 install instructions.

https://mirrors-obs-2.lolinet.com/firmware/motorola/2017/payton/official/FI/
    The location that the script tries to download the latest stock Android 9 ROM from.

https://forum.xda-developers.com/t/guide-video-text-how-to-flash-official-factory-firmware-moto-x4.3808348/
    The XDA developers forum post that the firmware flashing script is adapted from.
