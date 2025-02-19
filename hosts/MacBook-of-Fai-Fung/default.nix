{ config, pkgs, ... }:

{
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

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
  ];

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  programs.zsh.promptInit = "";

  # Allow sudo to use Touch ID
  security.pam.enableSudoTouchIdAuth = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  system.defaults.trackpad.ActuationStrength = 0;
  system.defaults.trackpad.Clicking = true;
  system.defaults.trackpad.Dragging = true;
  system.defaults.NSGlobalDomain."com.apple.trackpad.scaling" = 2.0;
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;
  system.activationScripts.postUserActivation.text = ''
    # Following line should allow us to avoid a logout/login cycle
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  users.users.fai = {
    name = "fai";
    home = "/Users/fai";
  };
}
