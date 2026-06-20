{
  stdenvNoCC,

  rkbin-src,
}:
{
  rkTrustConfig,
  src ? rkbin-src,
}:
stdenvNoCC.mkDerivation (finalAttrs: rec {
  name = "rkbin-bl31";

  inherit src;

  dontUnpack = true;
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    bl31="${src}/$(grep '^PATH=.*_bl31_' ${src}/RKTRUST/${rkTrustConfig} | cut -d = -f 2 -)"

    mkdir $out
    cp -- $bl31 $out/bl31.elf
  '';

  dontFixup = true;

  passthru = {
    elf = "${finalAttrs.finalPackage.out}/bl31.elf";
  };
})
