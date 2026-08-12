top @ {inputs, ...}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    inherit (config) craneLib commonArgs cargoArtifacts;
  in {
    checks = {
      inherit (config.packages) spl-token-cli;

      cargo-audit = craneLib.cargoAudit {
        inherit (top.config) src;
        inherit (inputs) advisory-db;
        inherit (commonArgs) pname version;
      };

      cargo-clippy = craneLib.cargoClippy (
        commonArgs
        // {
          inherit cargoArtifacts;
          cargoClippyExtraArgs = "-- --deny warnings";
        }
      );

      cargo-doc = craneLib.cargoDoc (
        commonArgs
        // {
          inherit cargoArtifacts;
        }
      );

      cargo-deny = craneLib.cargoDeny {
        inherit (top.config) src;
        cargoDenyChecks = "bans licenses sources";
      };

      cargo-fmt = craneLib.cargoFmt {
        inherit (top.config) src;
      };

      # cargo-nextest = craneLib.cargoNextest (
      #   commonArgs
      #   // {
      #     inherit cargoArtifacts;
      #     partitions = 1;
      #     partitionType = "count";
      #   }
      # );

      spl-token-cli-udeps = craneLib.mkCargoDerivation (
        commonArgs
        // {
          inherit cargoArtifacts;
          pnameSuffix = "-udeps";
          buildPhaseCargoCommand = "cargo udeps --locked --package spl-token-cli";
          doInstallCargoArtifacts = false;
          nativeBuildInputs =
            (commonArgs.nativeBuildInputs or [])
            ++ [
              pkgs.cargo-udeps
            ];
        }
      );
    };
  };
}
