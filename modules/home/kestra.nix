{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.programs.kestra;

  runArgs =
    [
      "--rm"
      "--name"
      cfg.containerName
      "-p"
      "${toString cfg.port}:8080"
      "-v"
      "${cfg.stateDir}:/app/storage"
    ]
    ++ cfg.extraPodmanArgs
    ++ [cfg.image "server" "local"];
in {
  options.programs.kestra = {
    enable = lib.mkEnableOption "Kestra workflow orchestration platform";

    package = lib.mkPackageOption pkgs "podman" {};

    image = mkOption {
      type = types.str;
      default = "docker.io/kestra/kestra:latest";
      description = ''
        OCI image reference for the Kestra server, run rootless via podman
        instead of Docker.
      '';
    };

    stateDir = mkOption {
      type = types.str;
      default = "${config.xdg.stateHome}/kestra";
      defaultText = lib.literalExpression ''"\${config.xdg.stateHome}/kestra"'';
      description = ''
        Host directory bind-mounted into the container at `/app/storage`,
        used by Kestra's local-storage backend and embedded H2 database in
        `server local` mode. Keep this directory persistent.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Host port published for the Kestra UI/API.";
    };

    containerName = mkOption {
      type = types.str;
      default = "kestra";
      description = "Name given to the podman container.";
    };

    extraPodmanArgs = mkOption {
      type = types.listOf types.str;
      default = [];
      example = lib.literalExpression ''["--memory=2g"]'';
      description = "Extra arguments inserted into `podman run` before the image reference.";
    };

    service = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to run Kestra as a systemd user service via podman.

          Only supported on Linux Home Manager hosts with systemd user
          services. Darwin users can still use the `kestra-server` launcher
          script this module installs and run it manually (a podman machine
          must already be running).
        '';
      };

      wantedBy = mkOption {
        type = types.listOf types.str;
        default = ["default.target"];
        description = "Systemd user targets that should start the Kestra service.";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.isLinux || !cfg.service.enable;
        message = "programs.kestra.service.enable is only supported on Linux systemd user sessions.";
      }
    ];

    home.packages = [
      cfg.package
      (pkgs.writeShellScriptBin "kestra-server" ''
        exec ${lib.getExe cfg.package} run -it ${lib.escapeShellArgs runArgs}
      '')
    ];

    home.activation.kestraStateDirectory = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg cfg.stateDir}
    '';

    systemd.user.services.kestra = mkIf cfg.service.enable {
      Unit = {
        Description = "Kestra workflow orchestration platform";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
      };

      Service = {
        ExecStartPre = "-${lib.getExe cfg.package} rm -f ${lib.escapeShellArg cfg.containerName}";
        ExecStart = "${lib.getExe cfg.package} run ${lib.escapeShellArgs runArgs}";
        ExecStop = "${lib.getExe cfg.package} stop ${lib.escapeShellArg cfg.containerName}";
        Restart = "on-failure";
      };

      Install.WantedBy = cfg.service.wantedBy;
    };
  };
}
