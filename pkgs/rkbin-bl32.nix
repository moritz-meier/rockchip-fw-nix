{
  stdenvNoCC,

  rkbin-src,
}:
{
  rkTrustConfig,
  src ? rkbin-src,
}:
stdenvNoCC.mkDerivation (finalAttrs: rec {
  name = "rkbin-bl32";

  inherit src;

  dontUnpack = true;
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    bl32="${src}/$(grep '^PATH=.*_bl32_' ${src}/RKTRUST/${rkTrustConfig} | cut -d = -f 2 -)"

    mkdir $out
    cp -- $bl32 $out/bl32.bin
  '';

  dontFixup = true;

  passthru = {
    bin = "${finalAttrs.finalPackage.out}/bl32.bin";
  };
})
