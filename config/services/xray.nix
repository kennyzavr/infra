{ self, ... }: {
  flake.alloyModules.infra =
    { config, ... }:
    let
      alloy = config;
    in
    {
      imports = [
        self.alloyModules.xray
      ];

      services.xray."main" = {
        host = "gallium";
        overlays."main" = { };
        domain = {
          zone = "public";
          name = "fb";
        };
        countryCodes = [
          "ru"
        ];
        fallbackEndpoint = "filebrowser";
        targets = {
          "phone-global-relay" = {
            remark = "Телефон · Полный · Через МСК";
            tun.enable = false;
            country.direct = false;
            address = alloy.hosts."iridium".nets."public".v4.advertiseAddress;
          };
          "phone-global-direct" = {
            remark = "Телефон · Полный · Прямой";
            tun.enable = false;
            country.direct = false;
            address = alloy.hosts."gallium".nets."public".v4.advertiseAddress;
          };
          "phone-split-relay" = {
            remark = "🔥 Телефон · Только иностранный · Через МСК";
            tun.enable = false;
            country.direct = true;
            address = alloy.hosts."iridium".nets."public".v4.advertiseAddress;
          };
          "phone-split-direct" = {
            remark = "Телефон · Только иностранный · Прямой";
            tun.enable = false;
            country.direct = true;
            address = alloy.hosts."gallium".nets."public".v4.advertiseAddress;
          };
          "desktop-global-relay" = {
            remark = "Компьютер · Полный · Через МСК";
            tun.enable = true;
            country.direct = false;
            address = alloy.hosts."iridium".nets."public".v4.advertiseAddress;
          };
          "desktop-global-direct" = {
            remark = "Компьютер · Полный · Прямой";
            tun.enable = true;
            country.direct = false;
            address = alloy.hosts."gallium".nets."public".v4.advertiseAddress;
          };
          "desktop-split-relay" = {
            remark = "Компьютер · Только иностранный · Через МСК";
            tun.enable = true;
            country.direct = true;
            address = alloy.hosts."iridium".nets."public".v4.advertiseAddress;
          };
          "desktop-split-direct" = {
            remark = "Компьютер · Только иностранный · Прямой";
            tun.enable = true;
            country.direct = true;
            address = alloy.hosts."gallium".nets."public".v4.advertiseAddress;
          };
        };
      };

      services.http-edge."public" = {
        routes."fb" = {
          domain = {
            zone = "public";
            name = "fb";
          };
          downstream.tls.mode = "only";
          downstream.tls.cert = "public-wildcard";
          upstream.endpoint = alloy.services.xray."main".tunnelEndpoint;
          addDnsRecords = false;
        };
        routes."bp" = {
          domain = {
            zone = "public";
            name = "bp";
          };
          downstream.tls.mode = "only";
          downstream.tls.cert = "public-wildcard";
          upstream.endpoint = alloy.services.xray."main".subsEndpoint;
        };
      };

      dns.records = [
        {
          domain = {
            zone = "public";
            name = "fb";
          };
          data.a = alloy.hosts."iridium".nets."public".v4.advertiseAddress;
        }
      ];

      endpoints."filebrowser" = {
        port = 443;
        targets = [
          {
            ip.v6 = alloy.jails."filebrowser".overlays."main".ipv6;
            overlay = "main";
          }
        ];
      };

      jails."filebrowser" =
        { config, ... }:
        let
          jail = config;
        in
        {
          host = "gallium";
          overlays."main" = { };
          endpoints."filebrowser" = { };
          mtls.permissions = {
            owner = "nginx";
            group = "nginx";
            mode = "0640";
          };
          volumes."db" = {
            path = "/var/lib/filebrowser";
            driver.directory = { };
            permissions = {
              owner = "filebrowser";
              group = "filebrowser";
              mode = "0750";
            };
          };
          nixosModule = {
            networking.firewall.allowedTCPPorts = [ 443 ];
            services.nginx = {
              enable = true;
              virtualHosts."_" = {
                default = true;
                listenAddresses = [ "[::]" ];
                onlySSL = true;
                sslCertificate = jail.mtls.certPath;
                sslCertificateKey = jail.mtls.keyPath;
                locations."/" = {
                  recommendedProxySettings = true;
                  proxyPass = "http://127.0.0.1:8080";
                };
              };
            };
            services.filebrowser = {
              enable = true;
              settings.port = 8080;
              settings.address = "127.0.0.1";
            };
          };
        };
    };
}
