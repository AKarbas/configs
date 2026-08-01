.PHONY: nixos nixos-debug darwin darwin-debug hm hm-debug update history gc fmt clean bootstrap zed-pull zed-push

NIXFLAGS := --extra-experimental-features 'nix-command flakes'
DEBUGFLAGS := --show-trace --verbose

ZED_DOTFILES := common/home/dotfiles/zed
ZED_LIVE := $(HOME)/.config/zed

# NixOS targets
nixos:
	nix build .#nixosConfigurations.UNiXOS.system $(NIXFLAGS)
	sudo ./result/bin/switch-to-configuration switch

nixos-debug:
	nix build .#nixosConfigurations.UNiXOS.system $(NIXFLAGS) $(DEBUGFLAGS)
	sudo ./result/bin/switch-to-configuration switch $(DEBUGFLAGS)

# Darwin targets
darwin:
	nix build .#darwinConfigurations.$(HOSTNAME).system $(NIXFLAGS)
	sudo ./result/sw/bin/darwin-rebuild switch --flake .#$(HOSTNAME)

darwin-debug:
	nix build .#darwinConfigurations.$(HOSTNAME).system $(NIXFLAGS) $(DEBUGFLAGS)
	sudo ./result/sw/bin/darwin-rebuild switch --flake .#$(HOSTNAME) $(DEBUGFLAGS)

# Standalone home-manager targets (foreign-distro Linux)
hm:
	nix build .#homeConfigurations.amin-linux.activationPackage $(NIXFLAGS)
	HOME_MANAGER_BACKUP_EXT=bak ./result/activate

hm-debug:
	nix build .#homeConfigurations.amin-linux.activationPackage $(NIXFLAGS) $(DEBUGFLAGS)
	HOME_MANAGER_BACKUP_EXT=bak ./result/activate

# Bootstrap
bootstrap:
	./bootstrap.sh

# Common targets
update:
	nix flake update $(NIXFLAGS)

history:
	nix profile history --profile /nix/var/nix/profiles/system

gc:
	sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d
	sudo nix store gc --debug

fmt:
	nix fmt .

clean:
	rm -rf result

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
HOSTNAME := $(shell scutil --get LocalHostName 2>/dev/null || echo Amin-Karbas-MacBook-Pro)
endif

ifeq ($(shell command -v nix 2>/dev/null),)
default: bootstrap
else ifeq ($(UNAME), Darwin)
default: darwin
else ifneq ($(wildcard /etc/NIXOS),)
default: nixos
else
default: hm
endif

.DEFAULT_GOAL := default
