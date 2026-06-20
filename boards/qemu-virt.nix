{
  applyPatches,
  edk2-src,
  pkgsCross,
  rkbin,
  rockchip,
  writeScript,
  qemu_full,
  runCommand,

  finalBoard,
}:
{
  uboot = pkgsCross.aarch64-multiplatform.uboot.build {
    defconfig = "qemu_arm64_defconfig";

    extraConfig = ''
      CONFIG_LOG=y
      CONFIG_CMD_LOG=y
      CONFIG_LOG_DEFAULT_LEVEL=4
      CONFIG_LOG_MAX_LEVEL=7
      CONFIG_LOG_CONSOLE=y

      CONFIG_NET_LWIP=y

      CONFIG_CMD_GPT=y
      CONFIG_CMD_GPT_RENAME=y
      CONFIG_CMD_EFIDEBUG=y
    '';

    outputFiles = {
      bin = "u-boot.bin";
    };
  };

  edk2 = (
    pkgsCross.aarch64-multiplatform.edk2.build {
      dsc = "ArmVirtPkg/ArmVirtQemu.dsc";
      buildConfig = "RELEASE";
      src = edk2-src;
      extraBuildFlags = [ ];

      outputFiles = {
        efi-fd = "Build/ArmVirtQemu-AArch64/RELEASE_GCC/FV/QEMU_EFI.fd";
        vars-fd = "Build/ArmVirtQemu-AArch64/RELEASE_GCC/FV/QEMU_VARS.fd";
      };
    }
  );

  uboot-vm = writeScript "run-uboot" ''
    ${qemu_full}/bin/qemu-system-aarch64 -M virt -cpu cortex-a76 -m 4G -nographic -serial mon:stdio \
      -bios ${finalBoard.uboot.bin} \
      $@
  '';

  edk2-vm =
    let
      pflash = runCommand "edk2-vm-pflash" { } ''
        mkdir $out
        dd of="$out/QEMU_EFI-pflash.raw" if="/dev/zero" bs=1M count=64
        dd of="$out/QEMU_EFI-pflash.raw" if=${finalBoard.edk2.efi-fd} conv=notrunc

        dd of="$out/QEMU_VARS-pflash.raw" if="/dev/zero" bs=1M count=64
        dd of="$out/QEMU_VARS-pflash.raw" if=${finalBoard.edk2.vars-fd} conv=notrunc
      '';
    in
    writeScript "run-edk2" ''
      ${qemu_full}/bin/qemu-system-aarch64 -M virt -cpu cortex-a76 -m 4G -nographic \
        -drive if=pflash,format=raw,readonly=on,file=${pflash}/QEMU_EFI-pflash.raw \
        -drive if=pflash,format=raw,snapshot=on,file=${pflash}/QEMU_VARS-pflash.raw \
        $@
    '';
}
