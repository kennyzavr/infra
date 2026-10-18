{
  flake.alloyModules.infra = { config, ... }: {
    hosts.gallium = { config, ... }: {

      ssh.enable = true;
      ssh.listen = [
        {
          net = "public";
          port = 22;
        }
      ];

      boot.ssh.enable = true;
      boot.ssh.port = 2022;
    };
  };

  flake.alloyModules.infra-prod = { ... }: {
    hosts.gallium = { config, ... }: {
      ssh.keys."host" = { };
      ssh.keys."initrd" = { };
      boot.files."ssh-initrd".source = config.ssh.keys."initrd".path;

      ssh.keyPaths = [ config.ssh.keys."host".path ];
      boot.ssh.keyPaths = [ config.boot.files."ssh-initrd".path ];

      users.admin.ssh.authKeyFacts = [
        "ssh/keys/yubikey_1.pub"
        "ssh/keys/yubikey_2.pub"
      ];
      boot.ssh.authKeyFacts = [
        "ssh/keys/yubikey_1.pub"
        "ssh/keys/yubikey_2.pub"
      ];

      workspace.secrets.age.keyPairs = [
        {
          identity = config.ssh.keys."host".path;
          recipient = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFwjd6X7tGlRHH6VCeOEDJ2ttQVK92YYXpPAfWCYdHTr";
        }
      ];
    };
  };

  flake.alloyModules.infra-test = { ... }: {
    hosts.gallium = { config, ... }: {
      ssh.listen = [
        {
          net = "slipr";
          port = 22;
        }
      ];
      ssh.keyPaths = [
        config.facts."test_ssh_key".path
      ];

      boot.ssh.authKeyFacts = [ "test_ssh_pub_key" ];
      boot.ssh.keyPaths = [ config.boot.facts."test_ssh_key".path ];

      qemu.forwardPorts = [
        {
          name = "ssh";
          hypervisor = 2271;
          guest = 22;
          proto = "tcp";
        }
        {
          name = "initrd ssh";
          hypervisor = 2270;
          guest = 2022;
          proto = "tcp";
        }
      ];

      users."admin".ssh.authKeyFacts = [
        "test_ssh_pub_key"
      ];
    };
  };
}
