dcache-scripts
==============

Some small dCache scripts that add functionality to dCache. It's probably very site specific to SURFsara but it may inspire others.

dcache-collect-debug-info.sh
----------------------------

Collects various debugging info, like heap dumps etc. You may have to adapt this script because it contains site specific hostnames.

get-file-checksum
-----------------

Talks to a dCache WebDAV door to obtain the checksum (Adler32 or MD5) of a file.

get-share-link
--------------

Talks to a dCache WebDAV door to obtain a macaroon: a token that authorizes anyone who gets it to access a certain dir or file with some caveats. Can also provide a direct link to access the shared object, or can list the curl commands you need to access it, or it can create an Rclone config file that provides access with Rcloe to the shared data. Uses view-macaroon (see below).

view-macaroon
-------------

A tiny Python script to deserialize (decode) a macaroon, so that you can see what's inside. Used by `get-share-link`. Uses pymacaroons (`pip install pymacaroons`).
