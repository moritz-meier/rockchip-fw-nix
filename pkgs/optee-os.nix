{
  buildPackages,
  dtc,
  lib,
  stdenv,

  optee-src,
  optee-examples-src,
  optee-ftpm-src,
  ms-tpm-20-ref-src,
}:
{
  plat,
  extraMakeFlags ? [ ],
  extraPatches ? [ ],
  # src ? optee-src,
  outputFiles ? { },
}:
stdenv.mkDerivation (finalAttrs: rec {
  name = "optee-os-${plat}";

  srcs = [
    optee-src
    optee-examples-src
    optee-ftpm-src
    ms-tpm-20-ref-src
  ];

  nativeBuildInputs = [
    dtc
    # https://github.com/NixOS/nixpkgs/issues/305858
    (buildPackages.python3.withPackages (
      p: with p; [
        pyelftools
        cryptography
      ]
    ))
  ];

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  makeFlags =
    let
      targetArch =
        {
          "arm" = "ta_arm32";
          "arm64" = "ta_arm64";
        }
        .${stdenv.hostPlatform.linuxArch};

      inherit (stdenv.hostPlatform) is32bit is64bit;
    in
    [
      "PLATFORM=${plat}"
      "CFG_USER_TA_TARGETS=${targetArch}"
      "O=./build"
    ]
    ++ (lib.optionals is32bit [
      "CFG_ARM32_core=y"
      "CROSS_COMPILE32=${stdenv.cc.targetPrefix}"
    ])
    ++ (lib.optionals is64bit [
      "CFG_ARM64_core=y"
      "CROSS_COMPILE64=${stdenv.cc.targetPrefix}"
    ])
    ++ extraMakeFlags;

  patches = [ ] ++ extraPatches;

  unpackPhase = ''
    cp -r -- ${optee-src} ./optee-os
    chmod a=rwX -R ./optee-os

    cp -r -- ${optee-examples-src} ./optee-examples
    chmod a=rwX -R ./optee-examples

    cp -r -- ${optee-ftpm-src} ./optee-ftpm
    chmod a=rwX -R ./optee-ftpm
  '';

  postPatch = ''
    patchShebangs $(find -type d -name scripts -printf '%p ')
  '';

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    pushd ./optee-os
    make ${(lib.strings.escapeShellArgs makeFlags)} -j $NIX_BUILD_CORES
    popd

    pushd ./optee-examples/hello_world/ta
    make ${(lib.strings.escapeShellArgs makeFlags)} TA_DEV_KIT_DIR=../../../optee-os/build/export-ta_arm64 -j $NIX_BUILD_CORES
    popd

    pushd ./optee-ftpm
    make ${(lib.strings.escapeShellArgs makeFlags)} CFG_MS_TPM_20_REF=${ms-tpm-20-ref-src} TA_DEV_KIT_DIR=../optee-os/build/export-ta_arm64 -j $NIX_BUILD_CORES
    popd

    pushd ./optee-os
    make ${(lib.strings.escapeShellArgs makeFlags)} CFG_EARLY_TA=y EARLY_TA_PATHS="../optee-examples/hello_world/ta/build/8aaaf200-2450-11e4-abe2-0002a5d5c51b.stripped.elf ../optee-ftpm/build/bc50d971-d4c9-42c4-82cb-343fb7f37896.stripped.elf" -j $NIX_BUILD_CORES
    popd

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r ./optee-os/build/. $out/

    runHook postInstall
  '';

  dontFixup = true;

  passthru =
    { } // (lib.attrsets.mapAttrs (name: value: "${finalAttrs.finalPackage.out}/${value}") outputFiles);
})
