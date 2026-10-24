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
          "default" = {
            remark = "🍓 Нидерланды · Основной";
            country.direct = true;
          };
          "default-tun" = {
            remark = "🍇 Нидерланды · Основной · Служебный";
            tun.enable = true;
            country.direct = true;
          };
          "no-routing" = {
            remark = "🍒 Нидерланды · Без роутинга";
            country.direct = false;
          };
          "no-routing-tun" = {
            remark = "🥝 Нидерланды · Без роутинга · Служебный";
            tun.enable = true;
            country.direct = false;
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
          data.a = alloy.hosts."gallium".nets."public".v4.advertiseAddress;
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
