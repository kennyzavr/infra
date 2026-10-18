{
  flake.alloyModules.infra-test = { ... }: {
    qemu.nets."main" = { };
  };
}
