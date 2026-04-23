{ config, pkgs, ... }:

{
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  nix.settings = {
    http-connections = 128;
    max-substitution-jobs = 128;
  };

  nix.gc = {
    automatic = true;
    interval = { Weekday = 1; Hour = 10; Minute = 0; };
    options = "--delete-older-than 30d";
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.hasklug
  ];

  # Homebrew managed applications
  homebrew.enable = true;
  homebrew.casks = [
    "ghostty"
    "maccy"
    "obsidian"
    "visual-studio-code"
  ];

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  programs.zsh.promptInit = "";

  # Allow sudo to use Touch ID
  security.pam.services.sudo_local.touchIdAuth = true;

  system.primaryUser = "fai";
  system.defaults.trackpad.ActuationStrength = 0;
  system.defaults.trackpad.Clicking = true;
  system.defaults.trackpad.Dragging = true;
  system.defaults.NSGlobalDomain."com.apple.trackpad.scaling" = 2.0;
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;
  system.activationScripts.activateSettings.text = ''
    # Following line should allow us to avoid a logout/login cycle
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  users.users.fai = {
    name = "fai";
    home = "/Users/fai";
  };
}
