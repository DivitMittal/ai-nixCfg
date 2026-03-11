{lib}: {
  lib = import ./lib.nix {inherit lib;};
  commands = import ./commands {inherit lib;};
  skills = import ./skills {inherit lib;};
  agents = import ./agents {inherit lib;};
  rules = import ./rules {inherit lib;};
}
