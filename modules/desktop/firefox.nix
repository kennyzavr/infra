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
                stylix.targets.firefox = {
                  enable = true;
                  colorTheme.enable = true;
                  profileNames = [ "default" ];
                };

                programs.firefox = {
                  enable = true;
                  nativeMessagingHosts = [
                    pkgs.keepassxc
                  ];
                  policies = {
                    DisableTelemetry = true;
                    DisableFirefoxStudies = true;
                    DisablePocket = true;
                    SanitizeOnShutdown = false;
                    EnableTrackingProtection = {
                      Value = true;
                      Category = "strict";
                      Fingerprinting = true;
                      Cryptomining = true;
                      EmailTracking = true;
                      SuspectedFingerprinting = true;
                    };
                    ExtensionSettings = {
                      "FirefoxColor@mozilla.com" = {
                        installation_mode = "force_installed";
                        install_url = "https://addons.mozilla.org/firefox/downloads/latest/firefox-color/latest.xpi";
                      };
                      "sponsorBlocker@ajay.app" = {
                        installation_mode = "force_installed";
                        install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
                      };
                      "uBlock0@raymondhill.net" = {
                        installation_mode = "force_installed";
                        install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
                      };
                      "keepassxc-browser@keepassxc.org" = {
                        installation_mode = "force_installed";
                        install_url = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi";
                      };
                      # vimium
                      "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
                        installation_mode = "force_installed";
                        install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
                      };
                      "foxyproxy@eric.h.jung" = {
                        installation_mode = "force_installed";
                        install_url = "https://addons.mozilla.org/firefox/downloads/latest/foxyproxy-standard/latest.xpi";
                      };
                    };
                  };
                  profiles.default = {
                    id = 0;
                    isDefault = true;
                    extensions.force = true;
                    settings = {
                      "geo.enabled" = false;
                      "browser.startup.page" = 3;
                      "sidebar.revamp" = true;
                      "sidebar.verticalTabs" = true;
                      "widget.use-xdg-desktop-portal.file-picker" = 1;
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
