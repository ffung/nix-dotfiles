#!env /bin/sh

nix build .#darwinConfigurations.MacBook-of-Fai-Fung.system --extra-experimental-features "nix-command flakes"
echo "Run 'sudo darwin-rebuild switch --flake .#MacBook-of-Fai-Fung' to activate"

# when making changes to nix.conf
# sudo launchctl kickstart -k system/org.nixos.nix-daemon
