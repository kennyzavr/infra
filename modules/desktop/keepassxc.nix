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
                xdg.autostart.enable = true;

                programs.keepassxc = {
                  enable = true;
                  autostart = true;
                  settings = {
                    Browser.UpdateBinaryPath = false;
                    Browser.Enabled = true;
                    GUI = {
                      AdvancedSettings = true;
                      ApplicationTheme = "Classic";
                      CompactMode = true;
                      HidePasswords = true;
                      ShowTrayIcon = true;
                      MinimizeToTray = true;
                      MinimizeOnStartup = true;
                      MinimizeOnClose = true;
                      SearchWaitForEnter = true;
                    };
                    FdoSecrets = {
                      Enabled = true;
                    };
                  };
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
