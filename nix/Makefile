.PHONY: nixos nixos-debug darwin darwin-debug update history gc fmt clean bootstrap

# NixOS targets
nixos:
	cd nixos && nix build .#nixosConfigurations.UNiXOS.system \
		--extra-experimental-features 'nix-command flakes'
	cd nixos && sudo ./result/bin/switch-to-configuration switch

nixos-debug:
	cd nixos && nix build .#nixosConfigurations.UNiXOS.system --show-trace --verbose \
		--extra-experimental-features 'nix-command flakes'
	cd nixos && sudo ./result/bin/switch-to-configuration switch --show-trace --verbose

# Darwin targets
darwin:
	cd darwin && nix build .#darwinConfigurations.$(HOSTNAME).system \
		--extra-experimental-features 'nix-command flakes'
	cd darwin && sudo ./result/sw/bin/darwin-rebuild switch --flake .#$(HOSTNAME)

darwin-debug:
	cd darwin && nix build .#darwinConfigurations.$(HOSTNAME).system --show-trace --verbose \
		--extra-experimental-features 'nix-command flakes'
	cd darwin && sudo ./result/sw/bin/darwin-rebuild switch --flake .#$(HOSTNAME) --show-trace --verbose

# Bootstrap
bootstrap:
	./bootstrap.sh

# Common targets
update:
	cd darwin && nix flake update
	cd nixos && nix flake update

history:
	nix profile history --profile /nix/var/nix/profiles/system

gc:
	sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d
	sudo nix store gc --debug

fmt:
	cd darwin && nix fmt
	cd nixos && nix fmt

clean:
	rm -rf darwin/result nixos/result

# Detect system and set default target
UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
HOSTNAME := $(shell scutil --get LocalHostName 2>/dev/null || echo UNiCORN)
default: darwin
else
default: nixos
endif

.DEFAULT_GOAL := default
