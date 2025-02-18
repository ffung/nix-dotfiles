#!env /bin/sh

nix build .#darwinConfigurations.MacBook-of-Fai-Fung.system --extra-experimental-features "nix-command flakes"
