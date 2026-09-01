{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          self.overlays.default
          self.overlays.boards
        ];
      };

      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
    in
    {
      packages.${system} = {

        opi5plus = pkgs.rockchip-boards.orangepi-5-plus;
        qemu-virt = pkgs.rockchip-boards.qemu-virt;

        uboot-tools = pkgs.pkgsCross.aarch64-multiplatform.uboot.tools;
      };

      devShells.${system} = {
        default = pkgs.mkShell {
          packages = with pkgs; [
            binwalk
            dtc
            rkdeveloptool
            uboot.tools

            pkgsCross.aarch64-multiplatform.stdenv.cc
          ];
        };
      };

      # for `nix fmt`
      formatter.${system} = treefmtEval.config.build.wrapper;

      # for `nix flake check`
      checks.${system}.formatting = treefmtEval.config.build.check self;

      overlays = {
        default = import ./pkgs.nix;
        boards = import ./boards.nix;
      };
    };
}
