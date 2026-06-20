final: prev: {
  rockchip-boards = {
    orangepi-5-plus = prev.callPackage ./boards/orangepi-5-plus.nix {
      finalBoard = final.rockchip-boards.orangepi-5-plus;
    };

    qemu-virt = prev.callPackage ./boards/qemu-virt.nix {
      finalBoard = final.rockchip-boards.qemu-virt;
    };
  };
}
