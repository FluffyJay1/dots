# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# enable portage completions and gentoo prompt for zsh
autoload -U compinit promptinit
compinit
promptinit; prompt gentoo

export EDITOR="/usr/bin/nvim"

# when entering visual mode, edit line in vim
autoload edit-command-line; zle -N edit-command-line
bindkey -M vicmd v edit-command-line

alias vim="nvim"
alias doasedit="doas nvim"
alias itop="doas intel_gpu_top"
alias dgit='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

setopt HIST_IGNORE_SPACE # commands that start with a space don't get saved in the history
setopt NO_EQUALS # if a word starts with =, the part after it gets treated as a command, and the word gets substituted with the path to the command

# vi insert mode backspace past start point
bindkey -v '^?' backward-delete-char

# https://codeberg.org/dnkl/foot/wiki
# spawn a new foot window with the current directory with ctrl + shift + n
# can only be done with some codes
function osc7 {
    setopt localoptions extendedglob
    input=( ${(s::)PWD} )
    uri=${(j::)input/(#b)([^A-Za-z0-9_.\!~*\'\(\)-\/])/%${(l:2::0:)$(([##16]#match))}}
    print -n "\e]7;file://${HOSTNAME}${uri}\e\\"
}
add-zsh-hook -Uz chpwd osc7

# clifm to use doas instead of sudo
export CLIFM_SUDO_CMD="doas"

# copied from /usr/share/clifm/functions/cd_on_quit.sh
# run clifm with alias 'c', cd on quit
c() {
	\clifm "--cd-on-quit" "$@"
	dir="$(grep "^\*" "${XDG_CONFIG_HOME:=${HOME}/.config}/clifm/.last" 2>/dev/null | cut -d':' -f2)";
  echo $dir
	if [ -d "$dir" ]; then
		cd -- "$dir" || return 1
	else
		printf "No directory specified\n" >&2
	fi
}
  
# only start p10ktheme if not in tty
case $(tty) in 
  (/dev/tty[1-9]);;
  (*)
    # powerlevel theme
    source ~/.config/zsh/powerlevel10k/powerlevel10k.zsh-theme
    # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    ;;
esac

function settitle () {
  print -Pn "\e]0;$@\e\\"
}

function precmd {
  settitle "zsh%L %(1j,%j job%(2j|s|); ,)%~"
}

function preexec {
  settitle "${(q)1}"
}

# The following lines were added by compinstall

zstyle ':completion:*' auto-description 's(%d)'
zstyle ':completion:*' completer _complete _list _ignored _correct _approximate _expand 
zstyle ':completion:*' completions 1
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' format 'c(%d)'
zstyle ':completion:*' glob 1
zstyle ':completion:*' group-name ''
zstyle ':completion:*' ignore-parents parent pwd ..
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=** r:|=**'
zstyle ':completion:*' max-errors 2
zstyle ':completion:*' menu select=long
zstyle ':completion:*' original false
zstyle ':completion:*' preserve-prefix '//[^/]##/'
zstyle ':completion:*' prompt 'e:(%e)'
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*' substitute 1
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' word true
zstyle :compinstall filename '/home/fluffyjay1/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=20000
setopt autocd beep nomatch notify
# End of lines configured by zsh-newuser-install
