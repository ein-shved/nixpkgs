{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-24.05;
    home-manager = {
      url = github:nix-community/home-manager/release-24.05;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = github:numtide/flake-utils;
    nvchad = {
      url = github:ein-shved/NvChad/v2.0;
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    agenix = {
      url = github:ryantm/agenix/0.14.0;
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    ide-manager = {
      url = github:ein-shved/ide/v0.3.0;
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    kompas3d = {
      url = github:ein-shved/nix-kompas3d;
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    gitwatch = {
      url = github:ein-shved/gitwatch;
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    yandex-music = {
      url = github:cucumber-sp/yandex-music-linux;
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };
  outputs =
    { self
    , nixpkgs
    , flake-utils
    , agenix
    , kompas3d
    , gitwatch
    , yandex-music
    , ...
    } @ attrs:
    let
      _modules = [
        ./config
        ./modules
        ./pkgs
        agenix.nixosModules.default
        kompas3d.nixosModules.default
        yandex-music.nixosModules.default
        { nixpkgs.overlays = [ agenix.overlays.default ]; }
      ]
      ++ gitwatch.modules;
      mkConfigs = hosts: flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          _lib = import ./lib { lib = pkgs.lib; };

          mkDevShellFor = config: name: pkgs.mkShell {
            packages = builtins.filter
              (pkg: pkgs.lib.getName pkg.name == name)
              config.environment.systemPackages;
          };

          mkDevShellsFor = with builtins; config: names:
            listToAttrs (map
              (name: { inherit name; value = mkDevShellFor config name; })
              names);

          mkConfig =
            { hostname
            , specialArgs ? { }
            , modules ? [ ]
            ,
            }: nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = {
                lib = pkgs.lib // _lib;
                inherit system;
              } // attrs // specialArgs;
              modules = _modules ++ modules;
            };
        in
        rec {
          packages = {
            nixosConfigurations = builtins.mapAttrs
              (hostname: v: mkConfig (v // { inherit hostname; }))
              hosts;
          };
          devShells = mkDevShellsFor
            packages.nixosConfigurations.generic.config [ "neovim" ];
        });

      mkConfig =
        { hostname
        , ...
        } @ attrs: mkConfigs { ${hostname} = attrs; };

      extend = self: { modules ? [ ]
                     , specialArgs ? { }
                     , prefix ? [ ]
                     , hosts ? { }
                     , ...
                     }@extraArgs:
        let
          mapConfigurations = configurations:
            builtins.mapAttrs
              (
                name: config:
                  let
                    globalExtended = config.extendModules {
                      inherit modules specialArgs prefix;
                    };
                    localExtended = globalExtended.extendModules
                      (if hosts ? ${name} then hosts.${name} else { });
                  in
                  localExtended
              )
              configurations;
          mapSystems = systems:
            builtins.mapAttrs
              (name: system:
                {
                  nixosConfigurations = mapConfigurations system.nixosConfigurations;
                })
              systems;
          updModules = self.modules ++ modules;
          updSelf = self // {
            packages = mapSystems self.packages;
            extend = extend updSelf;
            modules = updModules;
            inherit mkConfig;
          } // extraArgs;
        in
        updSelf;

      allConfigurations = mkConfigs (
        {
          generic = {
            modules = [{
              user.name = "NixOS";
            }];
          };
          # Run with
          # nixos-rebuild build-vm --flake .#testA && \
          # QEMU_NET_OPTS="hostfwd=tcp::2221-:22" ./result/bin/run-nixos-vm
          testA = {
            modules = [
              ./test/vm/configuration.nix
              {
                user = {
                  name = "alice";
                  humanName = "Alice Cooper";
                  password = "alice";
                };
                kl.remote.enable = true;
              }
            ];
          };
          testB = {
            modules = [
              ./test/vm/configuration.nix
              {
                user = {
                  name = "bob";
                  humanName = "Bob";
                  password = "bob";
                };
                environment.printing3d.enable = true;
                kl.domain.enable = true;
              }
            ];
          };
        }
        // import ./hosts
      );

    in
    extend ({ modules = _modules; } // allConfigurations) { };
}
