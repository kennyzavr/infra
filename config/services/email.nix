{ self, ... }: {
  flake.alloyModules.infra =
    { config, ... }:
    let
      alloy = config;
    in
    {
      imports = [
        self.alloyModules.postbox
      ];

      services.postbox."public" = {
        domain = {
          zone = "public";
          name = "@";
        };
        overlays."main" = { };
        host = "iridium";
        smtp.relayEndpoint = alloy.services.smtp-edge."public".endpoint;
      };

      services.http-edge."public" = {
        routes."mail" = {
          domain = {
            zone = "public";
            name = "mail";
          };
          downstream.tls.mode = "only";
          downstream.tls.cert = "public-wildcard";
          upstream.endpoint = alloy.services.postbox."public".https.endpoint;
        };
      };

      services.tls-edge."public" = {
        routes."mail-smtps" = {
          domain = {
            zone = "public";
            name = "mail";
          };
          downstream.port = 465;
          downstream.tls.cert = "public-wildcard";
          upstream.endpoint = alloy.services.postbox."public".smtps.endpoint;
        };
        routes."mail-imap" = {
          domain = {
            zone = "public";
            name = "mail";
          };
          downstream.port = 993;
          downstream.tls.cert = "public-wildcard";
          upstream.endpoint = alloy.services.postbox."public".imap.endpoint;
        };
      };

      services.smtp-edge."public" = {
        routes."mail-smtp" = {
          domain = {
            zone = "public";
            name = "@";
          };
          upstream.endpoint = alloy.services.postbox."public".smtp.endpoint;
        };
      };
    };
}
