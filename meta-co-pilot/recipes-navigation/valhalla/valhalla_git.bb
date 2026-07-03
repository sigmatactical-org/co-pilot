# Valhalla — offline routing engine
# Full build integration pending; enable when cross-compile recipe is validated.
#
# Upstream: https://github.com/valhalla/valhalla

SUMMARY = "Valhalla offline routing engine (placeholder)"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

ALLOW_EMPTY:${PN} = "1"

do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_install[noexec] = "1"

RDEPENDS:${PN} = "sqlite3 protobuf"
