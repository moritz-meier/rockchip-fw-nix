{
  pkgsCross,
  rkbin,
  rockchip,

  finalBoard,
}:
{
  rkbin-loader = rkbin.mkLoader { rkBootConfig = "RK3588MINIALL.ini"; };
  rkbin-tpl = rkbin.mkTpl { rkBootConfig = "RK3588MINIALL.ini"; };
  rkbin-bl31 = rkbin.mkBl31 { rkTrustConfig = "RK3588TRUST.ini"; };
  rkbin-bl32 = rkbin.mkBl32 { rkTrustConfig = "RK3588TRUST.ini"; };

  tfa = pkgsCross.aarch64-multiplatform.trustedFirmwareA.build rec {
    plat = "rk3588";
    extraMakeFlags = [
      "CFLAGS=-fomit-frame-pointer" # otherwise secondary cores do not boot correctly
      "SPD=opteed"
    ];

    outputFiles = {
      elf = "${plat}/release/bl31/bl31.elf";
    };
  };

  optee = pkgsCross.aarch64-multiplatform.optee.build {
    plat = "rockchip-rk3588";

    extraMakeFlags = [
      "CFG_CORE_RESERVED_SHM=n"
      "CFG_CORE_DYN_SHM=y"
      "CFG_DRAM_BASE=0x00000000"
      "CFG_DRAM_SIZE=0xf0000000"
    ];

    outputFiles = {
      bin = "core/tee.bin";
    };
  };

  uboot = pkgsCross.aarch64-multiplatform.uboot.build {
    defconfig = "orangepi-5-plus-rk3588_defconfig";
    extraMakeFlags = [
      "ROCKCHIP_TPL=${finalBoard.rkbin-tpl.bin}"
      "BL31=${finalBoard.tfa.elf}"
      "TEE=${finalBoard.optee.bin}"
    ];

    extraConfig = ''
      CONFIG_NET_LWIP=y

      CONFIG_TEE=y
      CONFIG_OPTEE=y
      CONFIG_OPTEE_LIB=y
      CONFIG_CMD_OPTEE=y

      CONFIG_ENV_IS_IN_FAT=y
      CONFIG_ENV_IS_NOWHERE=n
      CONFIG_ENV_FAT_INTERFACE="mmc"
      CONFIG_ENV_FAT_DEVICE_AND_PART="0:2"

      CONFIG_LOG=y
      CONFIG_LOG_DEFAULT_LEVEL=4
      CONFIG_LOG_MAX_LEVEL=7
      CONFIG_LOG_CONSOLE=y
      CONFIG_CMD_LOG=y
    '';

    outputFiles = {
      boot-bin = "u-boot-rockchip.bin";
      boot-spi-bin = "u-boot-rockchip-spi.bin";
    };
  };

  flash-spi-script = rockchip.mkFlashScript {
    name = "orangepi-5-plus";
    target = "spi";
    loader = finalBoard.rkbin-loader.bin;
    bin = finalBoard.uboot.boot-spi-bin;
  };

  flash-emmc-script = rockchip.mkFlashScript {
    name = "orangepi-5-plus";
    target = "emmc";
    loader = finalBoard.rkbin-loader.bin;
    bin = finalBoard.uboot.boot-bin;
  };

  # edk2 =
  #   let
  #     edk2-rk3588-src-patched = applyPatches {
  #       name = "edk2-rk3588-src-patched";
  #       src = edk2-rk3588-src;

  #       postPatch = ''
  #         for patch_file in "./edk2-patches/*.patch"; do
  #           patch -p1 -d ./edk2 < $patch_file
  #         done
  #       '';
  #     };
  #   in
  #   pkgsCross.aarch64-multiplatform.edk2.build {
  #     dsc = "edk2-rockchip/Platform/OrangePi/OrangePi5Plus/OrangePi5Plus.dsc";
  #     buildConfig = "RELEASE";
  #     src = edk2-rk3588-src-patched;
  #     edk2Path = "./edk2";
  #     packagesPath = [
  #       "devicetree"
  #       "edk2"
  #       "edk2-non-osi"
  #       "edk2-platforms"
  #       "edk2-rockchip"
  #       "edk2-rockchip-non-osi"
  #     ];

  #     extraBuildFlags = [
  #       "-D FIRMWARE_VER=${edk2-rk3588-src-patched.rev}"
  #       "-D DEFAULT_KEYS=TRUE"
  #       "-D PK_DEFAULT_FILE=${../keys/pk.cer}"
  #       "-D KEK_DEFAULT_FILE1=${../keys/ms_kek.cer}"
  #       "-D DB_DEFAULT_FILE1=${../keys/ms_db1.cer}"
  #       "-D DB_DEFAULT_FILE2=${../keys/ms_db2.cer}"
  #       "-D DBX_DEFAULT_FILE1=${../keys/arm64_dbx.bin}"
  #       "-D SECURE_BOOT_ENABLE=TRUE"
  #       "-D NETWORK_ALLOW_HTTP_CONNECTIONS=TRUE"
  #       "-D NETWORK_ISCSI_ENABLE=TRUE"
  #       "-D INCLUDE_TFTP_COMMAND=TRUE"
  #       "--pcd gRockchipTokenSpaceGuid.PcdFitImageFlashAddress=0x100000"
  #     ];
  #   };
}
