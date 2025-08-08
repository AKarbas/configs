I use the `nix/{darwin,nixos}` dirs to configure my machines. There's some
stuff (eg my editor configuration) I've not put here as they aren't complicated
anyway and I don't switch machines often enough to care. To try, replace all
instances of my username (`amin`) and the machine names (`UNiCORN` for darwin
and `UNiXOS` for not) and run `make` in `./nix`.

Be warned, it'll remove all `brew` packages that aren't listed (see
`homebrew.onActivation.cleanup` in `./nix/darwin/modules/apps.nix`) and change
system configs.

Use at your own risk yada yada.
