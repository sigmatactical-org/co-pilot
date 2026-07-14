## This is information on the rust-snapshot (binary) used to build our current release.
## snapshot info is taken from rust/src/stage0
## Rust is self-hosting and bootstraps itself with a pre-built previous version of itself.
## The exact (previous) version that has been used is specified in the source tarball.
## The version is replicated here.
## TODO: find a way to add additional SRC_URIs based on the contents of an
##       earlier SRC_URI.

SNAPSHOT_VERSION = "1.96.0"

# TODO: Add hashes for other architecture toolchains as well.

# You can use scripts/rust-get-stage0.sh to update hashes
SRC_URI[rust-std-snapshot-x86_64.sha256sum] = "c09c7c646248f14f473f5f7a029af15ee57c3a9f9bc93dfa72d9621938586b82"
SRC_URI[rustc-snapshot-x86_64.sha256sum] = "7d7fa1d0cfb0fab71a956bb78f41107202c17f30ab56c45288e869a37fd9633d"
SRC_URI[cargo-snapshot-x86_64.sha256sum] = "dee75c3c8f9f600ad75bc0c93249e767d3047845a4dd668327ce43ab039ba266"

SRC_URI[rust-std-snapshot-aarch64.sha256sum] = "538e85452709687797d990579a491ff9b02f8bffba4a5d54cfa945e28868053e"
SRC_URI[rustc-snapshot-aarch64.sha256sum] = "76b1a6e8dd1636e364d4bbba685485ff44eee5ff6434add089bab4c703c7e19d"
SRC_URI[cargo-snapshot-aarch64.sha256sum] = "09ea03e74aa94e07db7bc00bd2ec1ad86d90a7348c89fde3909a8922543b949f"

SRC_URI[rust-std-snapshot-powerpc64le.sha256sum] = "347ff4e5dd463849f21391b9db90093dee33578d98f30b42bbb78b4777921747"
SRC_URI[rustc-snapshot-powerpc64le.sha256sum] = "36f98b29bf631e27e0aaa2ffc1e33eb585a8f3a93e60e4b64e355b4e2aec4ede"
SRC_URI[cargo-snapshot-powerpc64le.sha256sum] = "6315038d99cb0270694afd72155faf899aebb700dd14c51f5d7186bfad73ab9a"

SRC_URI += " \
    https://static.rust-lang.org/dist/${RUST_STD_SNAPSHOT}.tar.xz;name=rust-std-snapshot-${RUST_BUILD_ARCH};subdir=rust-snapshot-components \
    https://static.rust-lang.org/dist/${RUSTC_SNAPSHOT}.tar.xz;name=rustc-snapshot-${RUST_BUILD_ARCH};subdir=rust-snapshot-components \
    https://static.rust-lang.org/dist/${CARGO_SNAPSHOT}.tar.xz;name=cargo-snapshot-${RUST_BUILD_ARCH};subdir=rust-snapshot-components \
"

RUST_STD_SNAPSHOT = "rust-std-${SNAPSHOT_VERSION}-${RUST_BUILD_ARCH}-unknown-linux-gnu"
RUSTC_SNAPSHOT = "rustc-${SNAPSHOT_VERSION}-${RUST_BUILD_ARCH}-unknown-linux-gnu"
CARGO_SNAPSHOT = "cargo-${SNAPSHOT_VERSION}-${RUST_BUILD_ARCH}-unknown-linux-gnu"
