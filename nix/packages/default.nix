{
  perSystem = {config, ...}: let
    inherit
      (config)
      craneLib
      commonArgs
      commonArgsNative
      cargoArtifacts
      cargoArtifactsNative
      ;
  in {
    packages = {
      spl-token-cli = craneLib.buildPackage (commonArgs
        // {
          inherit cargoArtifacts;
          doCheck = false;
        });

      spl-token-cli-native = craneLib.buildPackage (commonArgsNative
        // {
          cargoArtifacts = cargoArtifactsNative;
          doCheck = false;
        });
    };
  };
}
