# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "uas" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.initrd.systemd.enable = true;
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/4ef2b79b-f7a4-40e3-9af0-ca36fc292a90";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."cryptoroot".device = "/dev/disk/by-uuid/6289cf54-a909-4d63-ba8d-3c475624c82f";

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/9963-99D4";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/c4127045-6d87-41da-bf06-ab1f7751aed1"; }];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.docker0.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno2.useDHCP = lib.mkDefault true;
  # networking.interfaces.tun0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
