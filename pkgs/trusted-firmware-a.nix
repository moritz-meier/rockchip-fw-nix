{
  buildPackages,
  dtc,
  lib,
  stdenv,

  tfa-src,
}:
{
  plat,
  extraMakeFlags ? [ ],
  extraPatches ? [ ],
  src ? tfa-src,
  outputFiles ? { },
}:
stdenv.mkDerivation (finalAttrs: rec {
  name = "trusted-firmware-a-${plat}";

  inherit src;

  nativeBuildInputs = [
    dtc
  ];

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  makeFlags = [
    "HOSTCC=$(CC_FOR_BUILD)"
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
    "CC=${stdenv.cc.targetPrefix}cc"
    "LD=${stdenv.cc.targetPrefix}cc"
    "AS=${stdenv.cc.targetPrefix}cc"
    "OC=${stdenv.cc.targetPrefix}objcopy"
    "OD=${stdenv.cc.targetPrefix}objdump"

    "PLAT=${plat}"
  ]
  ++ extraMakeFlags;

  patches = [ ] ++ extraPatches;

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    make ${(lib.strings.escapeShellArgs makeFlags)} -j $NIX_BUILD_CORES bl31

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r ./build/. $out/

    runHook postInstall
  '';

  dontFixup = true;

  passthru =
    { } // (lib.attrsets.mapAttrs (name: value: "${finalAttrs.finalPackage.out}/${value}") outputFiles);
})
