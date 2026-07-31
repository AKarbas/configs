# Intro

The `nix/` dir configures my machines through one flake:

- nix-darwin for the Macs,
- NixOS for `UNiXOS`,
- home-manager only, for Linux hosts that are not NixOS.

To try: replace all instances of my username (`amin`) and the host names
(see `nix/flake.nix`), then run `make` in `./nix`. `make` picks the target
for the current system: darwin, nixos, or hm (home-manager only).

Be warned: on macOS it removes all `brew` packages that are not listed (see
`homebrew.onActivation.cleanup` in `./nix/darwin/modules/apps-common.nix`)
and changes system configs.

Use at your own risk yada yada.

# Setup

Run `cd nix && make`. If nix is not installed, `make` runs `./bootstrap.sh`,
which installs [Determinate nix] (plus Homebrew on macOS) and runs the right
target.

Then do the manual steps that `bootstrap.sh` prints at the end.

[Determinate nix]: https://docs.determinate.systems/determinate-nix/
