{ ... }:
{
  # Workaround for https://github.com/NixOS/nixpkgs/issues/507531
  # `direnv`'s checkPhase invokes `fish ./test/direnv-test.fish`, but on
  # darwin nixpkgs-25.11 fish from cache.nixos.org has an invalid code
  # signature (root cause: https://github.com/NixOS/nix/pull/15638), so it
  # SIGKILLs and direnv fails to build. Disabling tests skips the broken
  # fish dep entirely. Safe here only because no fish anywhere in this
  # config — if you ever add fish, the binary itself will still be broken
  # until the upstream fix lands.
  #
  # Remove this overlay once the issue above is closed and a darwin
  # release-25.11 channel update has propagated through cache.nixos.org.
  nixpkgs.overlays = [
    (_: super: {
      direnv = super.direnv.overrideAttrs (_: { doCheck = false; });
    })
  ];
}
