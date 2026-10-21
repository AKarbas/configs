{ lib, ... }:
let
  useCaseHackConf = "/etc/nix/use-case-hack.conf";
in
{
  environment.etc."nix/nix.custom.conf".text = lib.mkAfter "!include ${useCaseHackConf}";

  system.activationScripts.preActivation.text = ''
    if /usr/sbin/diskutil info /nix | /usr/bin/grep -q 'Case-sensitive'; then
      echo 'use-case-hack = false' > ${useCaseHackConf}
    else
      echo 'use-case-hack = true' > ${useCaseHackConf}
    fi
  '';
}
