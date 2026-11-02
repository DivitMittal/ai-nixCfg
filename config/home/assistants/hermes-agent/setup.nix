{
  pkgs,
  customLib,
  ...
}: {
  programs.hermes-agent = {
    enable = true;
    # Official PyPI wheel via uvx on every system: the npm `hermes-agent` is an
    # unrelated third-party wrapper, and Nix builds pull the nemo-relay extra,
    # which has no x86_64-darwin wheel. Upstream caps Python at <3.14.
    package = customLib.mkUvxBin pkgs "hermes" "--python 3.12 --from hermes-agent hermes";
  };
}
