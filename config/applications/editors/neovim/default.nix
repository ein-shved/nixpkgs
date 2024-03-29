{ pkgs, nvchad, ... }:
{
  imports = nvchad.modules;
  config = {
    programs.neovim = {
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
      nvchad = {
        enable = true;
        custom = ./custom;
        runtimeInputs = with pkgs; [
          ctags
          cscope
          llvmPackages.clang-unwrapped
          nixd
          nixpkgs-fmt
          lua-language-server
          stylua
          neocmakelsp
          nodePackages.bash-language-server
          shfmt
          shellcheck
          codelldb
        ];
      };
    };
    environment.systemPackages = with pkgs; [
      neovide
    ];
  };
}
