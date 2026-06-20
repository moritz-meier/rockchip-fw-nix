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
        opi5plus-uboot = pkgs.rockchip-boards.orangepi-5-plus.uboot;
        opi5plus-edk2 = pkgs.rockchip-boards.orangepi-5-plus.edk2;
        opi5plus-flash = pkgs.rockchip-boards.orangepi-5-plus.flash-script;

        qemu-virt-uboot = pkgs.rockchip-boards.qemu-virt.uboot;
        qemu-virt-uboot-vm = pkgs.rockchip-boards.qemu-virt.uboot-vm;

        qemu-virt-edk2 = pkgs.rockchip-boards.qemu-virt.edk2;
        qemu-virt-edk2-vm = pkgs.rockchip-boards.qemu-virt.edk2-vm;

        uboot-tools = pkgs.pkgsCross.aarch64-multiplatform.uboot.tools;
      };

      devShells.${system} = {
        default = pkgs.mkShell {
          packages = [
            pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc

            pkgs.qemu_full
            pkgs.binwalk
            pkgs.dtc
            pkgs.hexyl
            pkgs.gptfdisk

            pkgs.uboot.tools

            pkgs.rkdeveloptool
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
