SUMMARY = "Dedicated cluster UI user account"
LICENSE = "MIT"

inherit useradd

ALLOW_EMPTY:${PN} = "1"

USERADD_PACKAGES = "${PN}"
USERADD_PARAM:${PN} = "-r -s /bin/false -d /var/lib/cluster -g ${SIGMA_RACER_WINGMAN_GROUP} -G wayland,render,video ${SIGMA_RACER_WINGMAN_USER}"
GROUPADD_PARAM:${PN} = "-r ${SIGMA_RACER_WINGMAN_GROUP}; -r wayland; -r render"

do_install[noexec] = "1"
