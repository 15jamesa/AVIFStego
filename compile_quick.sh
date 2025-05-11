#! /usr/bin/bash

#build aom
cd ~/ffmpeg_sources/aom_build
PATH="$HOME/bin:$PATH" make
make install

#Force ffmpeg to link dynamically to libaom
rm -v /usr/lib/libaom.a

#build ffmpeg
cd ~/ffmpeg_sources/ffmpeg
PATH="$HOME/bin:$PATH" make 
make install

#Move back to home directory
cd ~

beep
exit 0
