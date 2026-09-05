{
  writeShellScript,
  rkdeveloptool,
}:
{
  name,
  target,
  loader,
  bin,
}:
let
  targetIds = {
    emmc = 1;
    sd = 2;
    spi = 9;
  };

  offsets = {
    emmc = 64;
    sd = 64;
    spi = 0;
  };
in
writeShellScript "${name}-flash-${target}.sh" ''
  ${rkdeveloptool}/bin/rkdeveloptool db ${loader}

  ${rkdeveloptool}/bin/rkdeveloptool cs ${toString targetIds.${target}}
  ${rkdeveloptool}/bin/rkdeveloptool ef

  ${rkdeveloptool}/bin/rkdeveloptool wl ${toString offsets.${target}} ${bin}

  ${rkdeveloptool}/bin/rkdeveloptool rd
''
