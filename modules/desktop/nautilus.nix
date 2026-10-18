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
                home.packages = [
                  pkgs.nautilus
                ];

                xdg.mimeApps = {
                  enable = true;
                  defaultApplications = {
                    "inode/directory" = "org.gnome.Nautilus.desktop";
                  };
                };
              };

            nixosModule =
              { pkgs, config, ... }:
              {
                services.gvfs.enable = true;
                services.udisks2.enable = true;
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
