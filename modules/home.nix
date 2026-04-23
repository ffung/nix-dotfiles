{ config, pkgs, lib, nixcats, claude-code, ... }:

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

  programs.gpg.enable = true;

  programs.jq.enable = true;
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Fai Fung";
        email = "fai.fung@gmail.com";
      };
      credential.helper = "manager";
      credential."https://github.com/".username = "ffung";
      credential.useHttpPath = true;
      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        cm = "commit";
        df = "diff";
        lg = "log --oneline --graph --decorate";
        lga = "log --oneline --graph --decorate --all";
        lga1 = "log --oneline --graph --decorate --all -n 1";
        lga2 = "log --oneline --graph --decorate --all -n 2";
      };
    };

    signing.format = null;

    # userName = "Fai Fung";
    # userEmail = "fai.fung@gmail.com";

    includes = [
      {
        condition = "gitdir:~/work/xebia/**";
        contents = {
          user = {
            email = "ffung@xebia.com";
            signingKey = "DF8603B7";
          };

          commit.gpgSign = true;
        };
      }

      {
        condition = "gitdir:~/work/ns/**";
        contents = {
          user = {
            email = "fai.fung@ns.nl";
            signingKey = "1029D826357ECD6D";
          };

          commit.gpgSign = true;
        };
      }
    ];


  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell"; # Required for git_prompt_info
      plugins = [ "gitfast" "docker" "kubectl" "macos" "vagrant" "gnu-utils" ];
    };

    initContent = let
      zshConfigBeforeCompletion = lib.mkOrder 550 ''
      '';

      zshConfig = lib.mkOrder 1000 ''
        bindkey \^U backward-kill-line

        collapse_pwd() {
          echo "''${PWD/#$HOME/~}"
        }

        prompt_char() {
          if git rev-parse --is-inside-work-tree &>/dev/null; then
            echo '±'
          else
            echo '○'
          fi
        }

        show_virtual_env() {
          [[ -n "$VIRTUAL_ENV" ]] && echo "🐍"
        }

        build_prompt() {
          local venv='$(show_virtual_env)'
          local user_host='%{$fg[magenta]%}%n%{$reset_color%}@%{$fg[yellow]%}%m%{$reset_color%}'
          local short_path='%{$fg_bold[green]%}$(collapse_pwd)%{$reset_color%}'
          local git='$(git_prompt_info)'
          local symbol='$(prompt_char)'
          echo "''${venv}''${user_host} ''${short_path} ''${git} ''${symbol} "
        }

        setopt PROMPT_SUBST
        PROMPT="$(build_prompt)"

        # Customize git_prompt_info appearance
        ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}⎇ "
        ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
        ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}*"
        ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}✓"
      '';
    in lib.mkMerge [ zshConfigBeforeCompletion zshConfig ];

    sessionVariables = {
      LC_ALL = "en_US.UTF-8";
      LS_COLORS = "di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32";
      PAGER = "less -XF";
      EDITOR = "nvim";
    };

    shellAliases = {
      ll = "ls -l";
      tf = "terraform";
    };
  };

  home.packages = with pkgs; [
    git-credential-manager
    coreutils

    fd # 'find' alternative, used by among others telescope-nvim
    tree-sitter # parser generator
    ripgrep

    bash-language-server
    terraform-ls
    python312Packages.python-lsp-server

    vfkit #for podman https://github.com/NixOS/nixpkgs/issues/305868
    podman
    kubectl
    kind
    nodejs

    keybase

    nixcats.packages.${pkgs.stdenv.hostPlatform.system}.default
    claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}

