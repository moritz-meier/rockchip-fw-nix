{
  stdenvNoCC,
  rkbin-src,
}:
{
  rkBootConfig,
  src ? rkbin-src,
}:
stdenvNoCC.mkDerivation (finalAttrs: rec {
  name = "rkbin-tpl";

  inherit src;

  dontUnpack = true;
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    tpl="${src}/$(grep '^FlashData' ${src}/RKBOOT/${rkBootConfig} | cut -d = -f 2 -)"

    mkdir $out
    cp -- $tpl $out/tpl.bin
  '';

  dontFixup = true;

  passthru = {
    bin = "${finalAttrs.finalPackage.out}/tpl.bin";
  };
})
