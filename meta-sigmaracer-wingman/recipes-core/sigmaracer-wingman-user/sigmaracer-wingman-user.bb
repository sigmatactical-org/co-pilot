SUMMARY = "Dedicated cluster UI user account"
LICENSE = "MIT"

inherit useradd

ALLOW_EMPTY:${PN} = "1"

USERADD_PACKAGES = "${PN}"
USERADD_PARAM:${PN} = "-r -s /bin/false -d /var/lib/cluster -g ${SIGMARACER_WINGMAN_GROUP} -G wayland,render,video ${SIGMARACER_WINGMAN_USER}"
GROUPADD_PARAM:${PN} = "-r ${SIGMARACER_WINGMAN_GROUP}; -r wayland; -r render"

do_install[noexec] = "1"
