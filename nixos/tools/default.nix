{ pkgs, ... }:
with pkgs;
let
  ide = callPackage ./ide {};
  nixos-rebuild-offline = writeShellScriptBin "nixos-rebuild-offline" ''
    nixos-rebuild "$@" --option substitute false
  '';
in {
  imports = [
    ./make.nix
    ./python
    ./dhcps
    ./ack.nix
    ./dowork.nix
    ./udev.nix
    ./avr.nix
  ];
  config = {
    environment.systemPackages = [
        ide
        nixos-rebuild-offline
    ];
    virtualisation = {
      docker = {
        enable = true;
      };
    };
  };
}
