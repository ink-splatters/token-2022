{lib, ...}: {
  perSystem = {config, ...}: let
    inherit (config) craneLib commonArgs commonArgsNative;
    dummySrc = craneLib.mkDummySrc (commonArgs
      // {
        # Crane does not stub auto-discovered tests in test-only workspace crates.
        extraDummyScript = ''
          mkdir -p "$out/confidential/proof-tests/tests"
          touch "$out/confidential/proof-tests/tests/proof_test.rs"
        '';
      });
    mkArtifactsArgs = args:
      (builtins.removeAttrs args ["src"])
      // {
        inherit dummySrc;
        doCheck = false;
        buildPhaseCargoCommand = "cargoWithProfile build ${args.cargoExtraArgs}";
      };
  in {
    options = {
      cargoArtifacts = lib.mkOption {
        type = lib.types.package;
        default = craneLib.buildDepsOnly (mkArtifactsArgs commonArgs
          // {
            pname = "spl-token-cli";
            # Include dev dependencies for clippy offline mode:
            # cargoCheckExtraArgs = "--all-targets --all-features";
          });
      };
      cargoArtifactsNative = lib.mkOption {
        type = lib.types.package;
        default = craneLib.buildDepsOnly (mkArtifactsArgs commonArgsNative
          // {
            pname = "spl-token-cli-native";
          });
      };
    };
  };
}
