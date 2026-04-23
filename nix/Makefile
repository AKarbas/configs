.PHONY: nixos nixos-debug darwin darwin-debug update history gc fmt clean bootstrap zed-pull zed-push

ZED_DOTFILES := common/home/dotfiles/zed
ZED_LIVE := $(HOME)/.config/zed

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

# Zed config sync
# Pull live ~/.config/zed into the repo, redacting `ghp_*` tokens.
zed-pull:
	@for f in settings.json keymap.json; do \
		src="$(ZED_LIVE)/$$f"; dst="$(ZED_DOTFILES)/$$f"; \
		if [ ! -f "$$src" ]; then echo "skip $$f (no live file)"; continue; fi; \
		sed -E 's/ghp_[A-Za-z0-9_]+/ghp_.../g' "$$src" > "$$dst.tmp"; \
		if cmp -s "$$dst" "$$dst.tmp"; then \
			echo "no changes: $$f"; rm "$$dst.tmp"; \
		else \
			mv "$$dst.tmp" "$$dst"; \
			echo "updated: $$dst"; \
			diff -u --color=auto "$$src" "$$dst" || true; \
		fi; \
	done

# Push repo's zed config to live ~/.config/zed.
zed-push:
	@mkdir -p "$(ZED_LIVE)"
	@for f in settings.json keymap.json; do \
		src="$(ZED_DOTFILES)/$$f"; dst="$(ZED_LIVE)/$$f"; \
		if [ ! -f "$$src" ]; then echo "skip $$f (no repo file)"; continue; fi; \
		if cmp -s "$$src" "$$dst" 2>/dev/null; then \
			echo "no changes: $$f"; \
		else \
			cp -f "$$src" "$$dst"; chmod 644 "$$dst"; \
			echo "updated: $$dst"; \
		fi; \
	done

# Detect system and set default target
UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
HOSTNAME := $(shell scutil --get LocalHostName 2>/dev/null || echo UNiCORN)
default: darwin
else
default: nixos
endif

.DEFAULT_GOAL := default
