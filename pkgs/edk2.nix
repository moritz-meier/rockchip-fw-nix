{
  acpica-tools,
  buildPackages,
  dtc,
  lib,
  nasm,
  libuuid,
  stdenv,

  edk2-src,
}:
{
  dsc,
  buildConfig ? "RELEASE",
  edk2Path ? ".",
  packagesPath ? [ ],
  gccPrefix ? "GCC", # or GCC5
  extraBaseToolsMakeFlags ? [ ],
  extraBuildFlags ? [ ],
  extraPatches ? [ ],
  src ? edk2-src,
  outputFiles ? { },
}:
let
  targetArch =
    if stdenv.hostPlatform.isi686 then
      "IA32"
    else if stdenv.hostPlatform.isx86_64 then
      "X64"
    else if stdenv.hostPlatform.isAarch32 then
      "ARM"
    else if stdenv.hostPlatform.isAarch64 then
      "AARCH64"
    else if stdenv.hostPlatform.isRiscV64 then
      "RISCV64"
    else if stdenv.hostPlatform.isLoongArch64 then
      "LOONGARCH64"
    else
      throw "targetArch = ${targetArch} is not supported.";
in
stdenv.mkDerivation (finalAttrs: {
  name = "edk2";

  inherit src;

  nativeBuildInputs = [
    libuuid
    acpica-tools
    dtc
    nasm
    # https://github.com/NixOS/nixpkgs/issues/305858
    (buildPackages.python3.withPackages (pyPkgs: [ ]))
  ];

  buildInputs = [ libuuid ];

  depsBuildBuild = [
    buildPackages.stdenv.cc
  ];

  env = {
    "${gccPrefix}_${targetArch}_PREFIX" = "${stdenv.cc.targetPrefix}";
    NIX_CFLAGS_COMPILE = "-std=gnu11";
  };

  hardeningDisable = [
    "format"
  ];

  patches = [ ] ++ extraPatches;

  postPatch = ''
    patchShebangs ./${edk2Path}/BaseTools
  '';

  configurePhase = ''
    runHook preConfigure

    export WORKSPACE=$PWD/workspace
    export EDK_TOOLS_PATH="$PWD/${edk2Path}/BaseTools"

    PACKAGES_PATH="$PWD"
    for path in ${lib.strings.concatStringsSep " " packagesPath}; do
      PACKAGES_PATH+=":$PWD/$path"
    done
    export PACKAGES_PATH

    mkdir -p $WORKSPACE
    source ./${edk2Path}/edksetup.sh BaseTools

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    make -C ./${edk2Path}/BaseTools -j $NIX_BUILD_CORES ${lib.strings.concatStringsSep " " extraBaseToolsMakeFlags}
    build -a ${targetArch} -b ${buildConfig} -t ${gccPrefix} -p ${dsc} -n $NIX_BUILD_CORES ${lib.strings.concatStringsSep " " extraBuildFlags}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r $WORKSPACE/. $out/

    runHook postInstall
  '';

  dontFixup = true;

  passthru =
    { } // (lib.attrsets.mapAttrs (name: value: "${finalAttrs.finalPackage.out}/${value}") outputFiles);
})
