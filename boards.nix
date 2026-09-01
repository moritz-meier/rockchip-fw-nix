final: prev: {
  rockchip-boards =
    let
      lib = prev.lib;
      mkBoard =
        name: board: extra:
        let
          drvs = (lib.filterAttrs (_: y: lib.isDerivation y) (prev.callPackage board extra));
        in
        (prev.linkFarmFromDrvs name (lib.mapAttrsToList (_: drv: drv) drvs)).overrideAttrs (
          final: prev: { passthru = drvs // prev.passthru; }
        );
    in
    {
      orangepi-5-plus = mkBoard "orangepi-5-plus" ./boards/orangepi-5-plus.nix {
        finalBoard = final.rockchip-boards.orangepi-5-plus;
      };

      qemu-virt = mkBoard "qemu-virt" ./boards/qemu-virt.nix {
        finalBoard = final.rockchip-boards.qemu-virt;
      };
    };
}
