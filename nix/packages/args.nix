top @ {lib, ...}: let
  inherit (lib) optionals concatStringsSep toString;
  inherit (top.config) src;
in {
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    inherit
      (pkgs.llvmPackages_latest)
      stdenv
      clang
      bintools
      libcxx
      ;
    inherit (stdenv.hostPlatform) isDarwin;

    bindgenHook = pkgs.rustPlatform.bindgenHook.override {
      inherit clang;
    };
    cliCrate = config.craneLib.crateNameFromCargoToml {
      cargoToml = "${src}/clients/cli/Cargo.toml";
    };

    mkFlags = flags: concatStringsSep " " (map (x: "-C ${x}") flags);

    flags = [
      "linker=${clang}/bin/cc"
      "link-args=-fuse-ld=lld"
    ];

    CFLAGS = ["-O3 -pipe"];
    LDFLAGS = ["-fuse-ld=lld"];

    mkCommonArgs = args @ {flags, ...}:
      {
        src = config.craneLib.cleanCargoSource src;
        inherit (cliCrate) pname version;
        cargoExtraArgs = "--locked --package spl-token-cli";
        strictDeps = true;
        enableParallelBuilding = true;
        RUSTFLAGS = mkFlags flags;

        nativeBuildInputs = with pkgs;
          [
            pkg-config
            protobuf
          ]
          ++ optionals isDarwin [
            darwin.DarwinTools
          ]
          ++ [
            clang
            bintools
            bindgenHook
          ];

        buildInputs = with pkgs;
          [
            bzip2
            jemalloc
            libusb1
            openssl
            rocksdb
            zstd
          ]
          ++ optionals isDarwin [
            pkgs.apple-sdk_15
            libcxx
          ];

        env = {
          CARGO_PROFILE_RELEASE_LTO = "thin";
          OPENSSL_NO_VENDOR = true;
          ROCKSDB_INCLUDE_DIR = "${pkgs.rocksdb}/include";
          ROCKSDB_LIB_DIR = "${pkgs.rocksdb}/lib";
          ZSTD_SYS_USE_PKG_CONFIG = true;
        };

        CFLAGS = toString CFLAGS;
        LDFLAGS = toString LDFLAGS;
      }
      // (builtins.removeAttrs args ["flags"]);
  in {
    options = {
      commonArgs = lib.mkOption {
        type = lib.types.attrs;
        default = mkCommonArgs {inherit flags;};
      };

      commonArgsNative = lib.mkOption {
        type = lib.types.attrs;

        default = mkCommonArgs {
          flags = flags ++ ["target-cpu=native"];
          NIX_ENFORCE_NO_NATIVE = 0;

          CFLAGS = concatStringsSep " " (
            CFLAGS
            ++ ["-mcpu=native"]
          );
        };
      };
    };
  };
}
