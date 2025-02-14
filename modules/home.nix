{ config, pkgs, lib,  ... }:

{
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";
  home.file.".config/nixpkgs/config.nix".text = ''
    {
      allowBroken = true;
      allowUnfree = true;
    }
  '';
  home.file.".config/nix/nix.conf".text = "experimental-features = nix-command flakes";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    stdlib = ''
      declare -A direnv_layout_dirs
      direnv_layout_dir() {
          echo "''${direnv_layout_dirs[$PWD]:=$(
              echo -n "${config.xdg.cacheHome}"/direnv/layouts/
              echo -n "$PWD" | shasum | cut -d ' ' -f 1
          )}"
      }
    '';
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "rg --files --no-ignore-vcs --hidden" ;
  };

  programs.jq.enable = true;
  programs.zsh.enable = true;
  programs.zsh.autosuggestion.enable = true;
  programs.zsh.initExtraBeforeCompInit = ''
    function collapse_pwd {
      echo $(pwd | sed -e "s,^$HOME,~,")
    }

    function prompt_char {
      git branch >/dev/null 2>/dev/null && echo '±' && return
      echo '○'
    }
  '';
  programs.zsh.initExtra = ''
    bindkey \^U backward-kill-line
    # export PROMPT="$(show_virtual_env) %{$fg[magenta]%}%n%{$reset_color%}@%{$fg[yellow]%}%m%{$reset_color%} %{$fg_bold[green]%}$(collapse_pwd) %{$fg_bold[blue]%}$(git_prompt_info)%{$reset_color%} $(prompt_char)"
    PROMPT='%{$fg[magenta]%}%n%{$reset_color%}@%{$fg[yellow]%}%m%{$reset_color%} %{$fg_bold[green]%}$(collapse_pwd) %{$fg_bold[blue]%}$(git_prompt_info)%{$reset_color%} $(prompt_char) '
    ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[magenta]%}("
    ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg[magenta]%})%{$reset_color%}"
    ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%}!"
    ZSH_THEME_GIT_PROMPT_CLEAN=""
    export PIP_REQUIRE_VIRTUALENV=true
    if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
    if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

  '';
  programs.zsh.sessionVariables = {
    LC_ALL    = "en_US.UTF-8";
    LS_COLORS = "di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32";
    PAGER     = "less -XF";
  };
  programs.zsh.shellAliases = {
    ll = "ls -l";
    tf = "terraform";
  };
  programs.zsh.oh-my-zsh.enable = true;
  programs.zsh.oh-my-zsh.theme = "robbyrussell";
  programs.zsh.oh-my-zsh.plugins = [ "gnu-utils" "gitfast" "macos" "vagrant" "docker" "kubectl" ];

  programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withPython3 = true;

      extraConfig =
        builtins.concatStringsSep "\n" [
        (lib.strings.fileContents ./vim/vimrc)
        (lib.strings.fileContents ./vim/init.vim)];

      extraPackages = with pkgs; [
      ];

      plugins = with pkgs.vimPlugins; [
        nvim-lspconfig
        nvim-treesitter.withAllGrammars
        plenary-nvim
        popup-nvim
        telescope-nvim
        nvim-cmp
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp-cmdline
        vim-vsnip
        vim-vsnip-integ
        friendly-snippets
        vim-one
        vim-airline
        vim-sensible
        vim-fugitive
        vim-repeat
        vim-surround
        vim-unimpaired
        vim-vinegar
        supertab
        tabular
        vim-better-whitespace
        which-key-nvim
        mini-icons
        nvim-web-devicons
      ];
  };

  home.packages = with pkgs; [
    /* terraform-lsp */
    ripgrep
    kind
    kubectl
    nodejs
    podman
    tree-sitter
    vfkit #for podman https://github.com/NixOS/nixpkgs/issues/305868
  ];
}

