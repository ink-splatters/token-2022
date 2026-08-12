{lib, ...}: {
  # -C target-cpu=...
  # -mcpu=...
  options.cpu = lib.mkOption {
    type = lib.types.str;
    default = "apple-m1";
  };
}
