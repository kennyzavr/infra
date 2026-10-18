{
  flake.alloyModules.infra =
    { config, ... }:
    let
      alloy = config;
    in
    {
      services.ca."main" = {
        subject = "d108";
        domain = {
          zone = "public";
          name = "ca";
        };
        permittedDomains = [
          {
            zone = "public";
            name = "@";
          }
        ];
        acme = {
          enable = true;
        };
        overlays = {
          "main" = { };
        };
        host = "iridium";
      };

      tls.ca."main" = { };

      tls.certs."ca" = {
        domains = [
          {
            zone = "public";
            name = "ca";
          }
        ];
        ca = "main";
        src.acme = {
          acceptTerms = true;
          email = alloy.dns.zones."public".email;
          challenge.dns.dnsupdate = {
            server.endpoint = alloy.services.dns-acme."public".endpoint;
          };
        };
      };

      services.http-edge."public" = {
        routes."ca" = {
          domain = {
            zone = "public";
            name = "ca";
          };
          downstream.tls.mode = "only";
          downstream.tls.cert = "ca";
          upstream.endpoint = alloy.services.ca."main".endpoint;
        };
      };
    };
}
