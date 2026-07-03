FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Persistent /data mount for maps, logs, ride data, RAUC state
do_install:append() {
    if ! grep -q '/data' ${D}${sysconfdir}/fstab; then
        echo "LABEL=data  /data  ext4  defaults,noatime  0  2" >> ${D}${sysconfdir}/fstab
    fi
}
