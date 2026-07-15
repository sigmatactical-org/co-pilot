# Sigma Racer Wingman A/B boot selection (RAUC uboot backend contract).
#
# RAUC's uboot backend flips BOOT_ORDER and refills BOOT_x_LEFT after an
# install; this script consumes one attempt per boot and falls back to the
# other slot when a freshly-written slot never marks itself good (the
# rauc-mark-good service refills the booted slot's counter in userspace).
# NXP u-boot loads this as boot.scr from the boot FAT (bsp_script) before
# its built-in fallback env.

test -n "${BOOT_ORDER}" || setenv BOOT_ORDER "A B"
test -n "${BOOT_A_LEFT}" || setenv BOOT_A_LEFT 3
test -n "${BOOT_B_LEFT}" || setenv BOOT_B_LEFT 3

setenv rauc_slot
setenv rauc_part
for BOOT_SLOT in ${BOOT_ORDER}; do
  if test -n "${rauc_slot}"; then
    echo "RAUC: slot already selected, skipping ${BOOT_SLOT}"
  elif test "x${BOOT_SLOT}" = "xA"; then
    if test ${BOOT_A_LEFT} -gt 0; then
      setexpr BOOT_A_LEFT ${BOOT_A_LEFT} - 1
      setenv rauc_slot A
      setenv rauc_part rootfs_a
    fi
  elif test "x${BOOT_SLOT}" = "xB"; then
    if test ${BOOT_B_LEFT} -gt 0; then
      setexpr BOOT_B_LEFT ${BOOT_B_LEFT} - 1
      setenv rauc_slot B
      setenv rauc_part rootfs_b
    fi
  fi
done

if test -n "${rauc_slot}"; then
  echo "RAUC: booting slot ${rauc_slot} (A left: ${BOOT_A_LEFT}, B left: ${BOOT_B_LEFT})"
  saveenv
else
  echo "RAUC: no bootable slot remaining, resetting"
  reset
fi

setenv bootargs console=${console} root=PARTLABEL=${rauc_part} rootwait rw rauc.slot=${rauc_slot}
# U-Boot's board detection presets ${fdtfile} (imx8mp-evk.dtb on the EVK);
# fall back to the machine's first devicetree when unset.
test -n "${fdtfile}" || setenv fdtfile @FDTFILE@

fatload mmc ${mmcdev}:${mmcpart} ${loadaddr} Image
fatload mmc ${mmcdev}:${mmcpart} ${fdt_addr} ${fdtfile}
booti ${loadaddr} - ${fdt_addr}
