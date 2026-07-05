# MapLibre Native — offline vector map rendering
# Full build integration pending; enable in IMAGE_INSTALL when recipe is complete.
#
# DEPENDS: cmake, sqlite3, libcurl, icu, harfbuzz, freetype, libpng, libwebp
# Upstream: https://github.com/maplibre/maplibre-native

SUMMARY = "MapLibre Native vector map renderer (placeholder)"
LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/BSD-2-Clause;md5=8da8f940b204e0269a2a1db2080803bf"

# Placeholder — pulls no packages until SRC_URI is wired to upstream release
ALLOW_EMPTY:${PN} = "1"

do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_install[noexec] = "1"

RDEPENDS:${PN} = "sqlite3"
