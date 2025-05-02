#! /usr/bin/bash

#delete old compilation
rm -rf ~/ffmpeg_build ~/bin/{ffmpeg,ffprobe,ffplay}
rm -rf ~/ffmpeg_sources/aom_build

#build aom
cd ~/ffmpeg_sources
mkdir -p aom_build
cd aom_build
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DBUILD_SHARED_LIBS=1 -DENABLE_TESTS=OFF -DENABLE_NASM=on ../aom
PATH="$HOME/bin:$PATH" make clean
make install

#Force ffmpeg to link dynamically to libaom
rm -v /usr/lib/libaom.a

#build ffmpeg
cd ~/ffmpeg_sources/ffmpeg
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="$HOME/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$HOME/ffmpeg_build/include -I$HOME/.julia/juliaup/julia-1.11.5+0.x64.linux.gnu/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib -L$HOME/.julia/juliaup/julia-1.11.5+0.x64.linux.gnu/lib -ljulia" \
  --extra-libs="-lpthread -lm" \
  --ld="g++" \
  --bindir="$HOME/bin" \
  --enable-libaom \
  --enable-shared \
  --disable-static
#was disable-shared + enable-static
PATH="$HOME/bin:$PATH" make clean
make install

#Help ffmpeg find shared object files 
cd ~
export LD_LIBRARY_PATH="$HOME/ffmpeg_build/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="$HOME/ffmpeg_build/lib:$HOME/.julia/juliaup/julia-1.11.5+0.x64.linux.gnu/lib:$LD_LIBRARY_PATH"

beep
exit 0
