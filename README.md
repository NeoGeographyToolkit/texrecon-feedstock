About texrecon-feedstock
========================

Feedstock license: [BSD-3-Clause](LICENSE.txt)

Home: https://github.com/NeoGeographyToolkit/mvs-texturing

Package license: BSD-3-Clause

Summary: The mesh-texturing stack for the Ames Stereo Pipeline (ASP), built as
ONE conda package: texrecon (mvs-texturing) plus the MVE libraries (mveCore,
mveUtil, mveDmrecon) and rayint headers it needs. mapmap is bundled as
build-time headers only.

This is one of the MultiView component breakup feedstocks, so that ASP
dependencies build as separate conda packages instead of inline in the
stereopipeline-feedstock build.

How it builds
-------------

The four sources (mve, mapmap, rayint, texrecon) are unpacked as sibling
folders and built with a trimmed top-level CMakeLists vendored in the recipe
(mve_texrecon_CMakeLists.txt), mirroring the MultiView layout that texrecon
expects (it references ${CMAKE_SOURCE_DIR}/{mve,rayint,mapmap}). The texrecon
binary installs as texrecon_bin.

Notes
-----

- zlib (headers) is an explicit host dep: libpng pulls only libzlib (runtime),
  so without zlib FindZLIB/FindPNG fail.
- x86-only flags (-march=native, -mfpmath=sse) are stripped from texrecon's
  CMakeLists so the package is portable across aarch64 machines.
