SUMMARY = "Sigma Racer Wingman platform users and groups"
LICENSE = "MIT"

inherit useradd

ALLOW_EMPTY:${PN} = "1"

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = "-r telemetry; -r ${SIGMA_RACER_WINGMAN_GROUP}; -r wayland; -r render"
USERADD_PARAM:${PN} = "\
    -r -s /bin/false -d /var/lib/cluster -g ${SIGMA_RACER_WINGMAN_GROUP} -G wayland,render,video,telemetry ${SIGMA_RACER_WINGMAN_USER}; \
    -r -s /bin/false -d /var/lib/vehicle -g telemetry ${SIGMA_RACER_WINGMAN_VEHICLE_USER} \
"

do_install[noexec] = "1"
