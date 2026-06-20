final: prev: {
  rkbin = {
    mkLoader = prev.callPackage ./pkgs/rkbin-loader.nix { };
    mkTpl = prev.callPackage ./pkgs/rkbin-tpl.nix { };
    mkBl31 = prev.callPackage ./pkgs/rkbin-bl31.nix { };
    mkBl32 = prev.callPackage ./pkgs/rkbin-bl32.nix { };
  };

  trustedFirmwareA = {
    build = prev.callPackage ./pkgs/trusted-firmware-a.nix { };
  };

  optee = {
    build = prev.callPackage ./pkgs/optee-os.nix { };
  };

  uboot = {
    build = prev.callPackage ./pkgs/uboot.nix { };
    tools = prev.callPackage ./pkgs/uboot-tools.nix { };
  };

  edk2 = {
    build = prev.callPackage ./pkgs/edk2.nix { };
  };

  rockchip = {
    mkFlashScript = prev.callPackage ./pkgs/flash-spi-cmd.nix { };
  };

  rkbin-src = prev.fetchFromGitHub {
    owner = "rockchip-linux";
    repo = "rkbin";
    rev = "master";
    hash = "sha256-U8d2cH6/TSXfBnLhh141A9wP/t6prFgwYMvwgXBf4vc=";
  };

  tfa-src = final.fetchgit {
    url = "https://review.trustedfirmware.org/TF-A/trusted-firmware-a";
    rev = "lts-v2.14.2";
    hash = "sha256-PaSx0gmbZe8KGGvafVo/xwSdGhZeW4/urSwZ7nipQoE=";
  };

  optee-src = final.fetchgit {
    url = "https://review.trustedfirmware.org/OP-TEE/optee_os";
    rev = "4.10.0";
    hash = "sha256-hdEvydnwn4VuImNvQ7exnB/f8AoxGMLadLh0S1gvXUc=";
  };

  uboot-src = prev.fetchFromGitHub {
    owner = "u-boot";
    repo = "u-boot";
    rev = "v2026.04";
    hash = "sha256-LobC22bYpHVGZd5G8IugfcmHacVaHH0aNe3zQG7LJv0=";
  };

  edk2-src = prev.fetchFromGitHub {
    owner = "tianocore";
    repo = "edk2";
    rev = "refs/heads/master";
    hash = "sha256-EhqHz/PPsRj/bOqYqMbSQ3J+EFP2xnYSKylBz/3HgIo=";

    fetchSubmodules = true;
  };

  edk2-rk3588-src = prev.fetchFromGitHub {
    owner = "edk2-porting";
    repo = "edk2-rk3588";
    rev = "refs/heads/master";
    hash = "sha256-Z1Klt0eQwiwkI2e6c6C+hDG7HM2/Mj+2kY8zmnsnGBg=";

    fetchSubmodules = true;
  };
}
