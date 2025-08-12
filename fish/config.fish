if status is-interactive
    # Init
    set fish_greeting
    starship init fish | source
    zoxide init fish | source

    # env
    set -x XDG_CONFIG_HOME "$HOME/.config"

    # Alias
    alias vim="nvim"
    alias cls="clear && printf '\e[3J'"
    alias fast="fastfetch --config examples/13.jsonc --logo /home/yuzujr/Pictures/fedora.png"
    alias ls="eza --icons -F -H --group-directories-first --git -1"
    alias ll="eza --icons -F -H --group-directories-first --git -1 -l"
    alias l="eza --icons -F -H --group-directories-first --git -1 -l"
    alias du="dust"
    alias df="duf -only local"
    alias cd="z"
    alias diff="delta"

    # Functions
    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end

    # Keybindings
    bind \cs 'for cmd in sudo doas please; if command -q $cmd; fish_commandline_prepend $cmd; break; end; end'
end
