{
  writeShellScript,
  rkdeveloptool,
}:
{
  name,
  loader,
  bin,
}:
writeShellScript "${name}-flash-spi.sh" ''
  ${rkdeveloptool}/bin/rkdeveloptool db ${loader}
  ${rkdeveloptool}/bin/rkdeveloptool ef

  ${rkdeveloptool}/bin/rkdeveloptool rd
  sleep 2

  ${rkdeveloptool}/bin/rkdeveloptool db ${loader}
  ${rkdeveloptool}/bin/rkdeveloptool wl 0 ${bin}

  ${rkdeveloptool}/bin/rkdeveloptool rd
''
