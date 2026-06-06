#!/usr/bin/env bash
set -ex

# Assemble the MultiView-style layout: mve, mapmap, rayint, texrecon are already
# unpacked as sibling folders under $SRC_DIR (one per source entry). Drop in the
# trimmed top-level CMakeLists (vendored in the recipe) that builds mve + rayint
# + texrecon (mapmap stays header-only). Flags mirror the MultiView section of
# stereopipeline-feedstock/recipe/build.sh: -std=c++17, -Wno-error,
# CMAKE_SKIP_INSTALL_RPATH=ON (avoids the macOS install_name_tool duplicate-rpath
# fatal; benign on linux, conda-build relocates rpath afterward).
cp "${RECIPE_DIR}/mve_texrecon_CMakeLists.txt" "${SRC_DIR}/CMakeLists.txt"

# texrecon hardcodes x86 flags under if(CMAKE_COMPILER_IS_GNUCXX):
#   -march=native -mfpmath=sse. On aarch64, -mfpmath=sse is rejected by gcc, and
# -march=native would bake the build host's CPU features into a package meant to
# run on other aarch64 machines (e.g. NCCS Grace) -> illegal-instruction risk.
# Strip both; keep -funroll-loops (portable). conda's baseline aarch64 flags
# already apply. Harmless no-op on x86 (this recipe pins gcc, so it always fires
# the GNUCXX branch).
perl -i -pe 's/-march=native//g; s/-mfpmath=sse//g;' "${SRC_DIR}/texrecon/CMakeLists.txt"

# NOTE: do NOT pass ${CMAKE_ARGS} here. conda's CMAKE_ARGS sets
# CMAKE_FIND_ROOT_PATH_MODE_{INCLUDE,LIBRARY}=ONLY, which breaks mve/texrecon's
# module-mode find_package(PNG/ZLIB/JPEG/TIFF) (Could NOT find PNG/ZLIB). The
# stereopipeline-feedstock MultiView build omits CMAKE_ARGS for the same reason
# and relies on CMAKE_PREFIX_PATH=MULTIVIEW_DEPS_DIR ($PREFIX) instead.
mkdir -p build && cd build
cmake                                                        \
    -DCMAKE_BUILD_TYPE=Release                               \
    -DMULTIVIEW_DEPS_DIR=${PREFIX}                           \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}                         \
    -DCMAKE_CXX_FLAGS="-O3 -std=c++17 -Wno-error -I${PREFIX}/include" \
    -DCMAKE_C_FLAGS='-O3 -Wno-error'                         \
    -DCMAKE_SKIP_INSTALL_RPATH=ON                            \
    -DCMAKE_VERBOSE_MAKEFILE=ON                              \
    ..
make -j${CPU_COUNT}
make install
