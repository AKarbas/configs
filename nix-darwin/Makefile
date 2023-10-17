.PHONY: darwin
darwin:
	nix build .#darwinConfigurations.UNiCORN.system \
		--extra-experimental-features 'nix-command flakes'

	./result/sw/bin/darwin-rebuild switch --flake .#UNiCORN

.PHONY: darwin-debug
darwin-debug: darwin-set-proxy
	nix build .#darwinConfigurations.UNiCORN.system --show-trace --verbose \
		--extra-experimental-features 'nix-command flakes'

	./result/sw/bin/darwin-rebuild switch --flake .#UNiCORN --show-trace --verbose

.PHONY: update
update:
	nix flake update

.PHONY: history
history:
	nix profile history --profile /nix/var/nix/profiles/system

.PHONY: gc
gc:
	sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d
	sudo nix store gc --debug

.PHONY: fmt
fmt:
	nix fmt

.PHONY: clean
clean:
	rm -rf result
