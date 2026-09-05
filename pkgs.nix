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

  rockchip = {
    mkFlashScript = prev.callPackage ./pkgs/flash-spi-cmd.nix { };
  };

  # edk2 = {
  #   build = prev.callPackage ./pkgs/edk2.nix { };
  # };

  rkbin-src = prev.fetchFromGitHub {
    owner = "rockchip-linux";
    repo = "rkbin";
    rev = "master";
    hash = "sha256-U8d2cH6/TSXfBnLhh141A9wP/t6prFgwYMvwgXBf4vc=";
  };

  tfa-src = prev.fetchgit {
    url = "https://review.trustedfirmware.org/TF-A/trusted-firmware-a";
    rev = "lts-v2.14.2";
    hash = "sha256-PaSx0gmbZe8KGGvafVo/xwSdGhZeW4/urSwZ7nipQoE=";
  };

  optee-src = prev.fetchgit {
    url = "https://review.trustedfirmware.org/OP-TEE/optee_os";
    rev = "4.10.0";
    hash = "sha256-hdEvydnwn4VuImNvQ7exnB/f8AoxGMLadLh0S1gvXUc=";
  };

  optee-examples-src = prev.fetchFromGitHub {
    owner = "linaro-swg";
    repo = "optee_examples";
    rev = "4.10.0";
    hash = "sha256-8SaicPUvU5lSJeSOhmd8L3bRiRpQrHteoYAoPmNpLJ8=";
  };

  optee-ftpm-src = prev.fetchFromGitHub {
    owner = "OP-TEE";
    repo = "optee_ftpm";
    rev = "4.10.0";
    hash = "sha256-WGEpDd+yokJinTFtN7W6phUZHxBoRaJq+hvmSsY3HXU=";
  };

  ms-tpm-20-ref-src = prev.fetchFromGitHub {
    owner = "microsoft";
    repo = "ms-tpm-20-ref";
    rev = "98b60a44aba79b15fcce1c0d1e46cf5918400f6a";
    hash = "sha256-s3VbhbFCcnXiZ+QZfC7b9Sw+ribYHNPEMcx8db9t09Q=";
  };

  uboot-src = prev.fetchFromGitHub {
    owner = "u-boot";
    repo = "u-boot";
    rev = "v2026.04";
    hash = "sha256-LobC22bYpHVGZd5G8IugfcmHacVaHH0aNe3zQG7LJv0=";
  };

  uboot-collabora-src = prev.fetchFromGitLab {
    domain = "gitlab.collabora.com";
    owner = "hardware-enablement";
    repo = "rockchip-3588/u-boot";
    rev = "rockchip";
    hash = "sha256-SAMN2vWgE0wKEP9QgYHluvU9WF9gY9Sq3vPIURZIVCo=";
  };

  edk2-src = prev.fetchFromGitHub {
    owner = "tianocore";
    repo = "edk2";
    rev = "edk2-stable202605";
    hash = "sha256-sUqLocdX7lxN2pEdn84Cjh8pOzYqIeKqO144XhwKA30=";

    fetchSubmodules = true;
  };

  edk2-rk3588-src = prev.fetchFromGitHub {
    owner = "edk2-porting";
    repo = "edk2-rk3588";
    rev = "refs/heads/master";
    hash = "";

    fetchSubmodules = true;
  };
}
