{
  flake.alloyModules.infra = { ... }: { };

  flake.alloyModules.infra-prod = { config, ... }: {
    tls.ca."letsencrypt".acme = {
      url = {
        path = "directory";
        server.address = "acme-v02.api.letsencrypt.org";
      };
    };

    tls.certs."public-wildcard" = {
      domains = [
        {
          zone = "public";
          name = "@";
        }
      ];
      ca = "letsencrypt";
      src.acme = {
        acceptTerms = true;
        wildcard = true;
        email = config.dns.zones."public".email;
        challenge.dns.dnsupdate = {
          server.endpoint = config.services.dns-acme."public".endpoint;
        };
      };
    };
  };

  flake.alloyModules.infra-test = { lib, config, ... }: {
    tls.certs."public-wildcard" = {
      domains = [
        {
          zone = "public";
          name = "@";
        }
      ];
      ca = "main";
      src.acme = {
        acceptTerms = true;
        wildcard = true;
        email = config.dns.zones."public".email;
        challenge.dns.dnsupdate = {
          server.endpoint = config.services.dns-acme."public".endpoint;
        };
      };
    };
  };
}
