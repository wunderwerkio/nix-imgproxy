{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.services.imgproxy;
in {
  options.services.imgproxy = {
    enable = mkEnableOption (mdDoc "Enable improxy service");

    package = lib.mkPackageOption pkgs "imgproxy" {};

    additionalEnv = mkOption {
      type = with types; attrsOf (oneOf [bool int str]);
      default = {};
    };
  };

  config = mkIf cfg.enable {
    systemd.services.imgproxy = {
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      environment = cfg.additionalEnv;
      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package}";
        Restart = "always";
        RestartSec = "10s";
        DynamicUser = true;
        NoNewPrivileges = true;
        # Sandboxing (sorted by occurrence in https://www.freedesktop.org/software/systemd/man/systemd.exec.html)
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHostname = true;
        ProtectClock = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
        RestrictNamespaces = true;
        LockPersonality = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        PrivateMounts = true;
        # System Call Filtering
        SystemCallArchitectures = "native";
        SystemCallFilter = ["~@cpu-emulation @debug @keyring @mount @obsolete @privileged @setuid"];
      };
    };
  };
}
