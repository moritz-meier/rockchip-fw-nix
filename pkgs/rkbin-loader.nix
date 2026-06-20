{
  stdenvNoCC,
  rkbin-src,
}:
{
  rkBootConfig,
  src ? rkbin-src,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  name = "rkbin-loader";

  inherit src;

  dontPatch = true;
  dontConfigure = true;

  buildPhase = ''
    ./tools/boot_merger RKBOOT/${rkBootConfig}
  '';

  installPhase = ''
    loader="./$(grep '^PATH=.*_loader_.*\.bin' ./RKBOOT/${rkBootConfig} | cut -d = -f 2 -)"

    mkdir $out
    cp -- $loader $out/spl-loader.bin
  '';

  dontFixup = true;

  passthru = {
    bin = "${finalAttrs.finalPackage.out}/spl-loader.bin";
  };
})
