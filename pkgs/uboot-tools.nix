{ uboot }:
(uboot.build { defconfig = "tools-only_defconfig"; }).overrideAttrs (
  final: prev: {
    installPhase = ''
      mkdir -p $out/bin
      find ./build/tools -type f -executable -exec cp {} $out/bin/ \;
    '';

    dontFixup = false;
  }
)
