# meta-rust setup_cargo_environment always appends SNAPSHOT_BUILD_SYS, but
# cargo_common_do_configure already writes the same Rust triple on native x86_64
# hosts — duplicate [target.*] tables break cargo 1.86+.
setup_cargo_environment () {
    cargo_common_do_configure

    if ! grep -qF "[target.${SNAPSHOT_BUILD_SYS}]" "${CARGO_HOME}/config"; then
        printf '[target.%s]\n' "${SNAPSHOT_BUILD_SYS}" >> ${CARGO_HOME}/config
        printf "linker = '%s'\n" "${RUST_BUILD_CCLD}" >> ${CARGO_HOME}/config
    fi
}
