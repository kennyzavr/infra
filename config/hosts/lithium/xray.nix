{
  flake.alloyModules.infra = { ... }: {
    hosts.lithium = { ... }: {
      xray."main" = {
        enable = true;
        client = "me-lithium";
        defaultTarget = "msk-tun-bypass";
      };
    };
  };

  flake.alloyModules.infra-prod = { ... }: {
    hosts.lithium = { ... }: { };
  };

  flake.alloyModules.infra-test = { ... }: {
    hosts.lithium = { ... }: { };
  };
}
