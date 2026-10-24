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
        allowWildcardCerts = true;
        acme = {
          enable = true;
        };
        overlays = {
          "main" = { };
        };
        host = "iridium";
      };

      tls.ca."main" = { };

      services.http-edge."public" = {
        routes."ca" = {
          domain = {
            zone = "public";
            name = "ca";
          };
          downstream.tls.mode = "only";
          downstream.tls.cert = "public-wildcard";
          upstream.endpoint = alloy.services.ca."main".endpoint;
        };
      };
    };
}
