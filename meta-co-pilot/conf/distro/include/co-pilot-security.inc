# Security, OTA, and read-only root filesystem options

# Enable in production local.conf:
#   DISTRO_FEATURES:append = " rauc read-only-rootfs tpm2"
#
# Secure boot is board-specific (CST / HAB on i.MX) — configure in meta-imx
# and board fuse programming workflow outside this layer.

# RAUC bundle signing key paths (override in local.conf, never commit keys)
# RAUC_KEY_FILE = "${TOPDIR}/../keys/rauc/development-key.pem"
# RAUC_CERT_FILE = "${TOPDIR}/../keys/rauc/development-ca.cert.pem"

# A/B partition labels used by wic and RAUC
CO_PILOT_SLOT_A_LABEL = "rootfs_a"
CO_PILOT_SLOT_B_LABEL = "rootfs_b"
CO_PILOT_BOOT_LABEL = "boot"
