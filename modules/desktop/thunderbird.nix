{
  flake.alloyModules.desktop =
    {
      alib,
      lib,
      config,
      ...
    }:
    let
      hostSubmodule =
        { config, name, ... }:
        let
          host = config;
        in
        {
          config = lib.mkIf host.desktop.enable {
            home.sharedModule =
              { pkgs, config, ... }:
              {
                xdg.autostart = {
                  enable = true;
                  entries = [
                    "${pkgs.thunderbird}/share/applications/thunderbird.desktop"
                  ];
                };

                xdg.mimeApps = {
                  enable = true;
                  defaultApplications = {
                    "x-scheme-handler/mailto" = "thunderbird.desktop";
                    "message/rfc822" = "thunderbird.desktop";
                  };
                };

                programs.thunderbird = {
                  enable = true;
                };
              };
          };
        };
    in
    {
      options.hosts = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule hostSubmodule);
      };
    };
}
