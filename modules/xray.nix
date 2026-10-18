{
  withSystem,
  ...
}:
{
  flake.alloyModules.xray =
    {
      alib,
      lib,
      config,
      ...
    }:
    let
      alloy = config;

      targetSubmodule = srvName: srv: { config, name, ... }: {
        options = {
          idx = lib.mkOption {
            type = lib.types.int;
            readOnly = true;
            default = alloy.indexes."xray/service/${srvName}/targets".get name;
          };
          remark = lib.mkOption {
            default = name;
            type = lib.types.str;
          };
          tun = {
            enable = lib.mkOption {
              default = false;
              type = lib.types.bool;
            };
            iface = lib.mkOption {
              readOnly = true;
              default = "xray-${toString srv.idx}-${toString config.idx}";
              type = lib.types.str;
            };
            systemWide.enable = lib.mkOption {
              default = false;
              type = lib.types.bool;
            };
          };
          country.direct = lib.mkOption {
            default = false;
            type = lib.types.bool;
          };
          address = lib.mkOption {
            default = null;
            type = lib.types.nullOr lib.types.str;
          };
        };
      };

      clientSubmodule =
        srvName: srv:
        { name, config, ... }:
        {
          options = {
            id = {
              secret = lib.mkOption {
                readOnly = true;
                default = "xray/${srvName}/clients/${name}/id";
                type = lib.types.str;
              };
              generator = lib.mkOption {
                readOnly = true;
                default = "xray/${srvName}/clients/${name}/id";
                type = lib.types.str;
              };
            };
          };
        };

      srvSubmodule = { config, name, ... }: {
        options = {
          enable = lib.mkOption {
            default = true;
            type = lib.types.bool;
          };
          idx = lib.mkOption {
            type = lib.types.int;
            readOnly = true;
            default = alloy.indexes."xray/services".get name;
          };
          path = {
            secret = lib.mkOption {
              readOnly = true;
              default = "xray/${name}/path";
              type = lib.types.str;
            };
            generator = lib.mkOption {
              readOnly = true;
              default = "xray/${name}/path";
              type = lib.types.str;
            };
          };
          domain = lib.mkOption {
            type = alib.types.zoneNode;
          };
          targets = lib.mkOption {
            default = { };
            type = lib.types.attrsOf (lib.types.submodule (targetSubmodule name config));
          };
          countryCodes = lib.mkOption {
            default = [ ];
            type = lib.types.listOf lib.types.str;
          };
          tunnelEndpoint = lib.mkOption {
            readOnly = true;
            type = lib.types.str;
            default = "xray-${name}-tunnel";
          };
          subsEndpoint = lib.mkOption {
            readOnly = true;
            type = lib.types.str;
            default = "xray-${name}-subs";
          };
          fallbackEndpoint = lib.mkOption {
            type = lib.types.str;
          };
          host = lib.mkOption {
            type = lib.types.str;
          };
          overlays = lib.mkOption {
            default = { };
            type = lib.types.attrsOf (lib.types.submodule { });
          };
          clients = lib.mkOption {
            default = { };
            type = lib.types.attrsOf (lib.types.submodule (clientSubmodule name config));
          };
        };
      };

      hostSubmodule =
        { config, name, ... }:
        let
          services = lib.pipe config.xray [
            (lib.filterAttrs (_: srv: srv.enable))
            (lib.mapAttrsToList (
              srvName: srvCfg: mkHostSrv name config srvName alloy.services.xray.${srvName} srvCfg
            ))
          ];
        in
        {
          options.xray = lib.mkOption {
            default = { };
            type = lib.types.attrsOf (
              lib.types.submodule {
                options = {
                  enable = lib.mkOption {
                    default = true;
                    type = lib.types.bool;
                  };
                  defaultTarget = lib.mkOption {
                    default = null;
                    type = lib.types.nullOr lib.types.str;
                  };
                  client = lib.mkOption {
                    type = lib.types.str;
                  };
                };
              }
            );
          };
          config = {
            overlays = lib.mkMerge (lib.map (s: s.overlays) services);
            secrets = lib.mkMerge (lib.map (s: s.secrets) services);
            secretTemplates = lib.mkMerge (lib.map (s: s.secretTemplates) services);
            nixosModule = {
              imports = lib.map (s: s.nixosModule) services;
            };
          };
        };

      mkServerConfigTemplate = srv: jail: ''
        {
          "log": {
              "loglevel": "debug"
          },
          "inbounds": [
            {
              "tag": "proxy",
              "listen": "127.0.0.1",
              "port": 8080,
              "protocol": "vless",
              "settings": {
                "decryption": "none",
                "clients": [${
                  lib.pipe srv.clients [
                    (lib.mapAttrsToList (
                      _: client: ''
                        {
                          "id": "${jail.secrets.${client.id.secret}.placeholder}",
                          "flow": ""
                        }
                      ''
                    ))
                    (lib.concatStringsSep ",\n")
                  ]
                }]
              },
              "sniffing": {
                "enabled": true,
                "destOverride": [
                  "http",
                  "tls",
                  "quic"
                ]
              },
              "streamSettings": {
                "network": "xhttp",
                "security": "none",
                "xhttpSettings": {
                  "path": "${jail.secrets.${srv.path.secret}.placeholder}",
                  "host": "${lib.removeSuffix "." (alloy.dns.resolveNode srv.domain)}",
                  "mode": "auto"
                }
              }
            }
          ],
          "outbounds": [
            {
                "protocol": "freedom",
                "settings": {
                    "sockopts": {
                        "domainStrategy": "UseIPv4"
                    }
                },
                "tag": "direct"
            },
            {
                "protocol": "blackhole",
                "tag": "block"
            }
          ],
          "dns": {
              "servers": [
                  "1.1.1.1"
              ]
          },
          "routing": {
            "domainStrategy": "IPIfNonMatch",
            "rules": [
              {
                  "domain": [
                      "geosite:category-ads-all"
                  ],
                  "outboundTag": "block",
                  "type": "field"
              },
              {
                  "ip": [
                      "geoip:private"
                  ],
                  "outboundTag": "block",
                  "type": "field"
              },
              {
                  "inboundTag": [
                      "proxy"
                  ],
                  "outboundTag": "direct",
                  "type": "field"
              }
            ]
          }
        }
      '';

      mkClientTargetConfigTemplate = srv: client: target: node: ''
        {
          "remarks": "${target.remark}",
          "inbounds": [
            ${lib.optionalString target.tun.enable ''
              {
                "tag": "tun-in",
                "protocol": "tun",
                "settings": {
                  "name": "${target.tun.iface}",
                  "gateway": [
                    "10.238.0.1/30"
                  ]
                  ${lib.optionalString target.tun.systemWide.enable '',
                    "autoSystemRoutingTable": [
                      "0.0.0.0/0"
                    ],
                    "autoOutboundsInterface": "auto"
                  ''}
                }
              },                
            ''}
            {
              "tag": "socks-in",
              "listen": "127.0.0.1",
              "port": 10808,
              "protocol": "socks",
              "settings": {
                "udp": true,
                "auth": "noauth"
              },
              "sniffing": {
                "enabled": true,
                "routeOnly": true,
                "destOverride": ["http", "tls", "quic"]
              }
            },
            {
              "tag": "http-in",
              "listen": "127.0.0.1",
              "port": 10809,
              "protocol": "http",
              "settings": {
                "udp": true,
                "auth": "noauth"
              },
              "sniffing": {
                "enabled": true,
                "routeOnly": true,
                "destOverride": ["http", "tls", "quic"]
              }
            }
          ],
          "outbounds": [
            {
              "tag": "proxy",
              "protocol": "vless",
              "settings": {
                "vnext": [
                  {
                    "address": ${
                      builtins.toJSON (
                        if target.address == null then
                          lib.removeSuffix "." (alloy.dns.resolveNode srv.domain)
                        else
                          target.address
                      )
                    },
                    "port": 443,
                    "users":  [
                      {
                        "id": "${node.secrets.${client.id.secret}.placeholder}",
                        "encryption": "none"
                      }
                    ]
                  }
                ]
              },
              "streamSettings": {
                "network": "xhttp",
                "security": "tls",
                "tlsSettings": {
                  "serverName": "${lib.removeSuffix "." (alloy.dns.resolveNode srv.domain)}"
                },
                "xhttpSettings": {
                  "path": "${node.secrets.${srv.path.secret}.placeholder}",
                  "host": "${lib.removeSuffix "." (alloy.dns.resolveNode srv.domain)}",
                  "mode": "auto"
                }
              }
            },
            {
              "protocol": "freedom",
              "settings": {
                "sockopts": {
                    "domainStrategy": "UseIPv4"
                }
              },
              "tag": "direct"
            },
            {
              "protocol": "blackhole",
              "tag": "block"
            }
          ],
          "dns": {
              "servers": [
                  "1.1.1.1",
                  "8.8.8.8",
                  "8.8.4.4"
              ],
              "queryStrategy": "UseIPv4"
          },
          "routing": {
            "domainStrategy": "AsIs",
            "domainMatcher": "hybrid",
            "rules": [
              {
                "domain": [
                  "geosite:category-ads-all"
                ],
                "outboundTag": "block",
                "type": "field"
              },
              {
                "ip": [
                    "geoip:private"
                ],
                "outboundTag": "direct",
                "type": "field"
              },
              ${lib.concatMapStringsSep "\n" (
                code:
                lib.optionalString (target.country.direct) ''
                  {
                      "domain": [
                          "geosite:category-${code}"
                      ],
                      "outboundTag": "direct",
                      "type": "field"
                  },
                  {
                      "ip": [
                          "geoip:${code}"
                      ],
                      "outboundTag": "direct",
                      "type": "field"
                  },
                ''
              ) srv.countryCodes}
              {
                "network": "tcp,udp",
                "outboundTag": "proxy",
                "type": "field"
              }
            ]
          }
        }
      '';

      mkSrv = srvName: srv: {
        assertions = [ ];

        indexes."xray/service/${srvName}/targets" = {
          minValue = 1;
          maxValue = 32;
          keys = builtins.attrNames srv.targets;
        };

        endpoints.${srv.tunnelEndpoint} = {
          port = 443;
          httpBuffering = false;
          targets = lib.mapAttrsToList (o: _: {
            ip.v6 = alloy.jails."xray-${srvName}".overlays.${o}.ipv6;
            overlay = o;
          }) srv.overlays;
        };

        endpoints.${srv.subsEndpoint} = {
          port = 8443;
          targets = lib.mapAttrsToList (o: _: {
            ip.v6 = alloy.jails."xray-${srvName}".overlays.${o}.ipv6;
            overlay = o;
          }) srv.overlays;
        };

        secrets = {
          ${srv.path.secret} = { };
        }
        // (lib.mapAttrs' (
          _: client:
          lib.nameValuePair client.id.secret {
          }
        ) srv.clients);

        generators.instances = {
          ${srv.path.generator} = {
            secrets.${srv.path.secret} = { };
            tags = [
              "xray"
              "xray/${srvName}"
            ];
            package =
              { system, ... }:
              let
                pkgs = withSystem system ({ pkgs, ... }: pkgs);
              in
              pkgs.writeShellApplication {
                name = "xray-path-generator";
                runtimeInputs = [ pkgs.util-linux ];
                text = ''
                  path="/$(uuidgen)"
                  "$ALLOY_BIN" secrets set ${lib.escapeShellArg srv.path.secret} <<< "$path"
                '';
              };
          };
        }
        // (lib.mapAttrs' (
          clientName: client:
          lib.nameValuePair client.id.generator {
            secrets.${client.id.secret} = { };
            tags = [
              "xray"
              "xray/${srvName}"
            ];
            wants = [ srv.path.generator ];
            package =
              { system, ... }:
              let
                pkgs = withSystem system ({ pkgs, ... }: pkgs);
              in
              pkgs.writeShellApplication {
                name = "xray-client-id-generator";
                runtimeInputs = [ pkgs.util-linux ];
                text = ''
                  id=$(uuidgen)
                  "$ALLOY_BIN" secrets set ${lib.escapeShellArg client.id.secret} <<< "$id"
                '';
              };
          }
        ) srv.clients);

        jails."xray-${srvName}" =
          { config, ... }:
          let
            jail = config;
          in
          {
            host = srv.host;

            tags = [
              "xray"
              "xray/${srvName}"
            ];

            uplink.allowEgress = true;

            overlays = lib.mapAttrs (_: _: { }) srv.overlays;

            endpoints.${srv.tunnelEndpoint} = { };
            endpoints.${srv.subsEndpoint} = { };

            mtls.permissions = {
              owner = "nginx";
              group = "nginx";
              mode = "0640";
            };

            secrets = {
              ${srv.path.secret} = {
                permissions = {
                  owner = "xray";
                  group = "xray";
                  mode = "0640";
                };
              };
            }
            // (lib.mapAttrs' (
              _: client:
              lib.nameValuePair client.id.secret {
                permissions = {
                  owner = "nginx";
                  group = "nginx";
                  mode = "0640";
                };
              }
            ) srv.clients);

            secretTemplates = {
              "server-config" = {
                permissions = {
                  owner = "xray";
                  group = "xray";
                  mode = "0640";
                };
                template = mkServerConfigTemplate srv jail;
              };
              "tunnel-locations" = {
                permissions = {
                  owner = "nginx";
                  group = "nginx";
                  mode = "0640";
                };
                template = ''
                  location ^~ ${jail.secrets."xray/${srvName}/path".placeholder}/ {
                    proxy_pass http://127.0.0.1:8080;

                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

                    proxy_buffering off;
                  }

                  location / {
                    proxy_pass http://unix:/run/nginx/xray-fallback.sock;

                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  }
                '';
              };
            }
            // (lib.mapAttrs' (
              clientName: client:
              lib.nameValuePair "client-${clientName}-sub" {
                template = ''
                  [
                    ${lib.concatMapAttrsStringSep ",\n" (
                      _: target: mkClientTargetConfigTemplate srv client target jail
                    ) srv.targets}
                  ]
                '';
                permissions = {
                  owner = "nginx";
                  group = "nginx";
                  mode = "0640";
                };
              }
            ) srv.clients);

            nixosModule = { pkgs, ... }: {
              networking.firewall.allowedTCPPorts = [
                443
                8443
              ];
              networking.firewall.allowedUDPPorts = [
                443
                8443
              ];

              users.users.xray = {
                isSystemUser = true;
                group = "xray";
              };
              users.groups.xray = { };

              systemd.services."xray-subs" = {
                after = [ "alloy-secrets-and-templates-setup.service" ];
                requires = [ "alloy-secrets-and-templates-setup.service" ];
                before = [ "nginx.service" ];
                wantedBy = [ "multi-user.target" ];
                requiredBy = [ "nginx.service" ];

                serviceConfig = {
                  Type = "oneshot";
                  RemainAfterExit = true;
                };

                script = ''
                  rm -rf /var/lib/xray-clients
                  mkdir -p /var/lib/xray-clients

                  ${lib.concatMapAttrsStringSep "\n" (clientName: client: ''
                    ln -sf "${jail.secretTemplates."client-${clientName}-sub".path}" "/var/lib/xray-clients/$(cat "${
                      jail.secrets.${client.id.secret}.path
                    }")"
                  '') srv.clients}
                '';
              };

              systemd.services.nginx = {
                after = [ "alloy-secrets-and-templates-setup.service" ];
                requires = [ "alloy-secrets-and-templates-setup.service" ];
              };

              services.nginx = {
                enable = true;
                virtualHosts."tunnel" = {
                  listen = [
                    {
                      addr = "[::]";
                      port = 443;
                      ssl = true;
                    }
                  ];
                  default = true;
                  onlySSL = true;
                  sslCertificate = jail.mtls.certPath;
                  sslCertificateKey = jail.mtls.keyPath;
                  http2 = true;
                  extraConfig = ''
                    proxy_buffering off;
                    ssl_client_certificate ${alloy.mtls.certPath};
                    ssl_verify_client on;
                    ssl_verify_depth 1;

                    include ${jail.secretTemplates."tunnel-locations".path};
                  '';
                };

                virtualHosts."subs" = {
                  listen = [
                    {
                      addr = "[::]";
                      port = 8443;
                      ssl = true;
                    }
                  ];
                  default = true;
                  onlySSL = true;
                  sslCertificate = jail.mtls.certPath;
                  sslCertificateKey = jail.mtls.keyPath;
                  http2 = true;
                  locations."/" = {
                    root = "/var/lib/xray-clients";
                    extraConfig = ''
                      autoindex off;
                      add_header Cache-Control "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0";
                      default_type application/json;
                      charset utf-8;
                    '';
                  };
                  extraConfig = ''
                    ssl_client_certificate ${alloy.mtls.certPath};
                    ssl_verify_client on;
                    ssl_verify_depth 1;
                  '';
                };

                virtualHosts."fallback" = {
                  listen = [
                    {
                      addr = "unix:/run/nginx/xray-fallback.sock";
                    }
                  ];
                  default = true;
                  locations."/" = {
                    recommendedProxySettings = true;
                    proxyPass =
                      let
                        fallback = alloy.endpoints.${srv.fallbackEndpoint};
                      in
                      "https://${fallback.domain}:${toString fallback.port}";
                  };
                  extraConfig = ''
                    proxy_ssl_certificate ${jail.mtls.certPath};
                    proxy_ssl_certificate_key ${jail.mtls.keyPath};
                    proxy_ssl_trusted_certificate ${alloy.mtls.certPath};
                    proxy_ssl_verify on;
                    proxy_ssl_verify_depth 1;
                  '';
                };
              };

              systemd.services.xray =
                let
                  unstablePkgs = withSystem pkgs.stdenv.hostPlatform.system (
                    { inputs', ... }: inputs'.nixpkgs-unstable.legacyPackages
                  );
                  assets = unstablePkgs.runCommand "xray-assets" { } ''
                    mkdir -p $out
                    ln -s ${unstablePkgs.v2ray-geoip}/share/v2ray/geoip.dat $out/geoip.dat
                    ln -s ${unstablePkgs.v2ray-domain-list-community}/share/v2ray/geosite.dat $out/geosite.dat
                  '';
                in
                {
                  after = [
                    "network.target"
                    "alloy-secrets-and-templates-setup.service"
                  ];
                  requires = [ "alloy-secrets-and-templates-setup.service" ];
                  wantedBy = [ "multi-user.target" ];
                  environment.XRAY_LOCATION_ASSET = assets;
                  serviceConfig = {
                    ExecStart = "${lib.getExe unstablePkgs.xray} run -format json -c ${
                      jail.secretTemplates."server-config".path
                    }";
                    User = "xray";
                    Group = "xray";
                    StateDirectory = "xray";
                    RuntimeDirectory = "xray";
                    RuntimeDirectoryPreserve = "yes";
                    ConfigurationDirectory = "xray";
                    CapabilityBoundingSet = "";
                    AmbientCapabilities = "";
                    NoNewPrivileges = true;
                    ProtectSystem = "strict";
                    ProtectHome = true;
                    PrivateTmp = true;
                    PrivateDevices = true;
                    PrivateMounts = true;
                    ProtectHostname = true;
                    ProtectClock = true;
                    ProtectKernelTunables = true;
                    ProtectKernelModules = true;
                    ProtectKernelLogs = true;
                    ProtectControlGroups = true;
                    ProtectProc = "invisible";
                    ProcSubset = "pid";
                    RemoveIPC = true;
                    RestrictAddressFamilies = [
                      "AF_INET"
                      "AF_INET6"
                      "AF_NETLINK"
                      "AF_UNIX"
                    ];
                    LockPersonality = true;
                    MemoryDenyWriteExecute = true;
                    RestrictRealtime = true;
                    RestrictSUIDSGID = true;
                  };
                };
            };
          };
      };

      mkHostSrv =
        hostName: host: srvName: srv: hostCfg:
        let
          client = srv.clients.${hostCfg.client};
        in
        {
          overlays = lib.mapAttrs (_: _: { }) srv.overlays;

          secrets = {
            ${srv.path.secret} = { };
            ${client.id.secret} = { };
          };

          secretTemplates = lib.mapAttrs' (
            targetName: target:
            lib.nameValuePair "xray-${srvName}-target-${targetName}" {
              template = mkClientTargetConfigTemplate srv client target host;
              permissions = {
                owner = "xray";
                group = "xray";
                mode = "0640";
              };
            }
          ) srv.targets;

          nixosModule =
            { pkgs, ... }:
            let
              unstablePkgs = withSystem pkgs.stdenv.hostPlatform.system (
                { inputs', ... }: inputs'.nixpkgs-unstable.legacyPackages
              );
              assets = unstablePkgs.runCommand "xray-assets" { } ''
                mkdir -p $out
                ln -s ${unstablePkgs.v2ray-geoip}/share/v2ray/geoip.dat $out/geoip.dat
                ln -s ${unstablePkgs.v2ray-domain-list-community}/share/v2ray/geosite.dat $out/geosite.dat
              '';
            in
            {
              users.users.xray = {
                isSystemUser = true;
                group = "xray";
              };
              users.groups.xray = { };

              environment.systemPackages = lib.mapAttrsToList (
                targetName: target:
                let
                  routingId = (srv.idx - 1) * alloy.indexes."xray/services".maxValue + target.idx;

                  packetMark = routingId * 65536;

                  sliceName = "xray_${toString srv.idx}_${toString target.idx}.slice";

                  routingUnit = "xray-${srvName}-${targetName}-routing.service";

                  registerCgroup = pkgs.writeShellApplication {
                    name = "xray-${srvName}-${targetName}-register";

                    runtimeInputs = [
                      pkgs.systemd
                      pkgs.nftables
                      pkgs.util-linux
                    ];

                    text = ''
                      if (( EUID != 0 )); then
                        echo "Run this helper through sudo" >&2
                        exit 1
                      fi

                      caller_uid="''${SUDO_UID:?Run this helper through sudo}"

                      if [[ ! "$caller_uid" =~ ^[0-9]+$ ]] || (( caller_uid == 0 )); then
                        echo "Expected a non-root caller" >&2
                        exit 1
                      fi

                      if ! systemctl is-active --quiet ${lib.escapeShellArg routingUnit}; then
                        echo "Routing service is not active: ${routingUnit}" >&2
                        exit 1
                      fi

                      manager_cgroup=$(
                        systemctl show "user@$caller_uid.service" \
                          --property=ControlGroup --value
                      )

                      if [[ -z "$manager_cgroup" || "$manager_cgroup" != /* ]]; then
                        echo "Cannot determine user manager cgroup" >&2
                        exit 1
                      fi

                      cgroup="''${manager_cgroup#/}/${sliceName}"

                      if [[ ! -d "/sys/fs/cgroup/$cgroup" ]]; then
                        echo "Cgroup does not exist: $cgroup" >&2
                        exit 1
                      fi

                      IFS=/ read -r -a components <<< "$cgroup"
                      level="''${#components[@]}"

                      table="xray_u''${caller_uid}_s${toString srv.idx}_t${toString target.idx}"

                      exec 9>"/run/lock/$table.lock"
                      flock -w 5 9

                      nft -f - <<EOF
                      destroy table inet $table

                      table inet $table {
                        chain output {
                          type route hook output priority mangle; policy accept;

                          meta nfproto ipv4 \
                            meta l4proto { tcp, udp } \
                            socket cgroupv2 level $level "$cgroup" \
                            counter \
                            meta mark set (meta mark & 0x0000ffff) | ${toString packetMark}
                        }
                      }
                      EOF
                    '';
                  };

                  launchInsideScope = pkgs.writeShellScript "xray-${srvName}-${targetName}-inside-scope" ''
                    set -euo pipefail

                    /run/wrappers/bin/sudo ${lib.getExe registerCgroup}

                    exec "$@"
                  '';

                  launcher = pkgs.writeShellApplication {
                    name = "xray-${srvName}-${targetName}-run";

                    runtimeInputs = [ pkgs.systemd ];

                    text = ''
                      if (( $# == 0 )); then
                        echo "Usage: xray-${srvName}-${targetName}-run COMMAND [ARGS...]" >&2
                        exit 1
                      fi

                      if (( EUID == 0 )); then
                        echo "Run the launcher as your desktop user" >&2
                        exit 1
                      fi

                      exec systemd-run \
                        --user \
                        --scope \
                        --slice=${lib.escapeShellArg sliceName} \
                        --expand-environment=no \
                        -- ${launchInsideScope} "$@"
                    '';
                  };
                in
                launcher
              ) srv.targets;

              networking.firewall.extraReversePathFilterRules = lib.concatMapAttrsStringSep "\n" (_: target: ''
                iifname "${target.tun.iface}" accept
              '') srv.targets;

              systemd.services = lib.pipe srv.targets [
                (lib.mapAttrsToList (
                  targetName: target: {
                    "xray-${srvName}-${targetName}" = {
                      conflicts = lib.pipe srv.targets [
                        (lib.filterAttrs (otherTargetName: _: otherTargetName != targetName))
                        (lib.mapAttrsToList (otherTargetName: _: "xray-${srvName}-${otherTargetName}.service"))
                      ];
                      requires = [ "alloy-secrets-and-templates-setup.service" ];
                      wantedBy = lib.optional (hostCfg.defaultTarget == targetName) "multi-user.target";
                      after = [
                        "network.target"
                        "alloy-secrets-and-templates-setup.service"
                      ]
                      ++ (lib.pipe srv.targets [
                        (lib.filterAttrs (otherTargetName: _: otherTargetName != targetName))
                        (lib.mapAttrsToList (otherTargetName: _: "xray-${srvName}-${otherTargetName}.service"))
                      ]);
                      environment.XRAY_LOCATION_ASSET = assets;
                      serviceConfig = {
                        ExecStart = "${lib.getExe unstablePkgs.xray} run -format json -c ${
                          host.secretTemplates."xray-${srvName}-target-${targetName}".path
                        }";
                        User = "xray";
                        Group = "xray";
                        StateDirectory = "xray";
                        RuntimeDirectory = "xray";
                        RuntimeDirectoryPreserve = "yes";
                        ConfigurationDirectory = "xray";
                        CapabilityBoundingSet = [
                          "CAP_NET_ADMIN"
                          "CAP_NET_RAW"
                        ];
                        AmbientCapabilities = [
                          "CAP_NET_ADMIN"
                          "CAP_NET_RAW"
                        ];
                        NoNewPrivileges = true;
                        ProtectSystem = "strict";
                        ProtectHome = true;
                        PrivateTmp = true;
                        PrivateDevices = false;
                        PrivateMounts = true;
                        ProtectHostname = true;
                        ProtectClock = true;
                        ProtectKernelTunables = true;
                        ProtectKernelModules = true;
                        ProtectKernelLogs = true;
                        ProtectControlGroups = true;
                        ProtectProc = "invisible";
                        ProcSubset = "pid";
                        RemoveIPC = true;
                        RestrictAddressFamilies = [
                          "AF_INET"
                          "AF_INET6"
                          "AF_NETLINK"
                          "AF_UNIX"
                        ];
                        LockPersonality = true;
                        MemoryDenyWriteExecute = true;
                        RestrictRealtime = true;
                        RestrictSUIDSGID = true;
                      };
                    };
                    "xray-${srvName}-${targetName}-routing" = {
                      after = [ "xray-${srvName}-${targetName}.service" ];
                      bindsTo = [ "xray-${srvName}-${targetName}.service" ];
                      partOf = [ "xray-${srvName}-${targetName}.service" ];
                      wantedBy = [ "xray-${srvName}-${targetName}.service" ];

                      path = [
                        pkgs.iproute2
                        pkgs.util-linux
                        pkgs.coreutils
                        pkgs.gnugrep
                      ];

                      serviceConfig = {
                        Type = "oneshot";
                        RemainAfterExit = true;
                        TimeoutStartSec = "20s";
                        TimeoutStopSec = "10s";
                      };

                      environment =
                        let
                          routingId = (srv.idx - 1) * alloy.indexes."xray/services".maxValue + target.idx;
                          packetMark = routingId * 65536;
                        in
                        {
                          XRAY_TUN_INTERFACE = target.tun.iface;
                          XRAY_MAIN_PRIORITY = toString (10000 + 2 * routingId);
                          XRAY_TUN_PRIORITY = toString (10001 + 2 * routingId);

                          XRAY_ROUTE_TABLE = toString (10000 + routingId);
                          XRAY_ROUTE_PROTOCOL = "242";

                          XRAY_MARK_VALUE = toString packetMark;
                          XRAY_MARK_MASK = "0xffff0000";
                          XRAY_PACKET_MARK = "${toString packetMark}/0xffff0000";
                        };

                      script = ''
                        set -euo pipefail

                        exec 9>"/run/lock/xray-routing-$XRAY_ROUTE_TABLE.lock"
                        flock -w 3 9

                        ready=false
                        for ((attempt = 0; attempt < 100; attempt++)); do
                          if ip -o -4 address show dev "$XRAY_TUN_INTERFACE" 2>/dev/null \
                              | grep -q ' inet '; then
                            ready=true
                            break
                          fi
                          sleep 0.1
                        done

                        if [[ "$ready" != true ]]; then
                          echo "TUN $XRAY_TUN_INTERFACE has no IPv4 address" >&2
                          exit 1
                        fi

                        ip -4 rule flush \
                          priority "$XRAY_TUN_PRIORITY" \
                          fwmark "$XRAY_PACKET_MARK" \
                          table "$XRAY_ROUTE_TABLE" \
                          protocol "$XRAY_ROUTE_PROTOCOL"

                        ip -4 rule flush \
                          priority "$XRAY_MAIN_PRIORITY" \
                          fwmark "$XRAY_PACKET_MARK" \
                          table main \
                          protocol "$XRAY_ROUTE_PROTOCOL"

                        ip -4 route replace default \
                          dev "$XRAY_TUN_INTERFACE" \
                          table "$XRAY_ROUTE_TABLE" \
                          proto "$XRAY_ROUTE_PROTOCOL"

                        ip -4 rule add \
                          priority "$XRAY_MAIN_PRIORITY" \
                          fwmark "$XRAY_PACKET_MARK" \
                          lookup main \
                          suppress_prefixlength 0 \
                          protocol "$XRAY_ROUTE_PROTOCOL"

                        ip -4 rule add \
                          priority "$XRAY_TUN_PRIORITY" \
                          fwmark "$XRAY_PACKET_MARK" \
                          lookup "$XRAY_ROUTE_TABLE" \
                          protocol "$XRAY_ROUTE_PROTOCOL"
                      '';

                      postStop = ''
                        set -euo pipefail

                        exec 9>"/run/lock/xray-routing-$XRAY_ROUTE_TABLE.lock"
                        flock -w 3 9

                        ip -4 rule flush \
                          priority "$XRAY_TUN_PRIORITY" \
                          fwmark "$XRAY_PACKET_MARK" \
                          table "$XRAY_ROUTE_TABLE" \
                          protocol "$XRAY_ROUTE_PROTOCOL"

                        ip -4 rule flush \
                          priority "$XRAY_MAIN_PRIORITY" \
                          fwmark "$XRAY_PACKET_MARK" \
                          table main \
                          protocol "$XRAY_ROUTE_PROTOCOL"

                        ip -4 route del default \
                          dev "$XRAY_TUN_INTERFACE" \
                          table "$XRAY_ROUTE_TABLE" \
                          proto "$XRAY_ROUTE_PROTOCOL" \
                          2>/dev/null || true
                      '';
                    };
                  }
                ))
                lib.mkMerge
              ];
            };
        };
    in
    {
      options.services.xray = lib.mkOption {
        default = { };
        type = lib.types.attrsOf (lib.types.submodule srvSubmodule);
      };

      options.hosts = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule hostSubmodule);
      };

      config =
        let
          services = lib.pipe alloy.services.xray [
            (lib.filterAttrs (_: srv: srv.enable))
            (lib.mapAttrsToList mkSrv)
          ];
        in
        {
          indexes = lib.mkMerge (
            (lib.singleton {
              "xray/services" = {
                minValue = 1;
                maxValue = 32;
                keys = builtins.attrNames alloy.services.xray;
              };
            })
            ++ (lib.map (s: s.indexes) services)
          );
          assertions = lib.mkMerge (lib.map (s: s.assertions) services);
          endpoints = lib.mkMerge (lib.map (s: s.endpoints) services);
          secrets = lib.mkMerge (lib.map (s: s.secrets) services);
          generators = lib.mkMerge (lib.map (s: s.generators) services);
          jails = lib.mkMerge (lib.map (s: s.jails) services);
        };
    };
}
