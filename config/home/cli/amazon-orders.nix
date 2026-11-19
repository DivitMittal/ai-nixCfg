{
  pkgs,
  customLib,
  ...
}: {
  # Resolve through uv so website-parser fixes can ship independently of nixpkgs.
  home.packages = [
    (customLib.mkUvxBin pkgs "amazon-orders" "--from amazon-orders amazon-orders")
  ];
}
