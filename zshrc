source /etc/profile
#
#######################################
# Options
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000

########################################
# Key Bindings

# Keys.
case $TERM in
    rxvt*)
    bindkey "^[[7~" beginning-of-line #Home key
    bindkey "^[[8~" end-of-line #End key
    bindkey "^[[3~" delete-char #Del key
    bindkey "^[[A" history-beginning-search-backward #Up Arrow
    bindkey "^[[B" history-beginning-search-forward #Down Arrow
    bindkey "^[Oc" forward-word # control + right arrow
    bindkey "^[Od" backward-word # control + left arrow
    bindkey "^H" backward-kill-word # control + backspace
    bindkey "^[[3^" kill-word # control + delete

    # Allow shift-tab to reverse in menu completion
    bindkey '^[[Z' reverse-menu-complete
    ;;

    linux)
    bindkey "^[[1~" beginning-of-line #Home key
    bindkey "^[[4~" end-of-line #End key
    bindkey "^[[3~" delete-char #Del key
    bindkey "^[[A" history-beginning-search-backward
    bindkey "^[[B" history-beginning-search-forward
    ;;
esac

#show mode of the vi-mode of zsh
#function zle-line-init zle-keymap-select {
#    RPS1="${${KEYMAP/vicmd/-- NORMAL --}/(main|viins)/-- INSERT --}"
#    RPS2=$RPS1
#    zle reset-prompt
#}
#zle -N zle-line-init
#zle -N zle-keymap-select

bindkey -e

########################################
# Colors in TTY
if [ "$TERM" = "linux" ]; then
    _SEDCMD='s/.*\*color\([0-9]\{1,\}\).*#\([0-9a-fA-F]\{6\}\).*/\1 \2/p'
    for i in $(sed -n "$_SEDCMD" $HOME/.Xdefaults | \
               awk '$1 < 16 {printf "\\e]P%X%s", $1, $2}'); do
        echo -en "$i"
    done
    clear
fi

########################################
# Other
autoload -U zmv

########################################
# Options
setopt no_clobber
setopt extendedGlob
setopt hist_ignore_dups
setopt noflowcontrol

########################################
# Exports

# In .zshenv

########################################
# Aliases
alias :q='exit'
alias :e='vim'

alias x='cd && xinit'
alias X='cd && xinit'

alias ls='ls --color=auto -F --group-directories-first'
alias lsa='ls -A --color=auto -F --group-directories-first'

alias rm='rm -Iv'
alias cp='cp -iv'
alias mv='mv -iv'

alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

alias rcp='rsync -hv --progress'
alias rmv='rsync -hv --progress --remove-source-files'

alias uz='7za'

export GREP_COLOR="1;32"   # some greps have colorized ouput. enable...
export GREPCOLOR="1;32"    # ditto here
alias grep='grep --color=auto' 

# get xprop CLASS and NAME
alias xp='xprop | ack "WM_CLASS"'
#alias fixres='xrandr --size 1280x800'

alias weechat='weechat-curses'
#alias wifi='wicd-curses'
alias tnethack='urxvtc -tn "rxvt-unicode" -e telnet nethack.alt.org & disown'

alias vimsession='vim -S '

alias o='xdg-open'

########################################
# Suffix Aliases 
# Video/Audio aliases
alias -s {mpg,mpeg,avi,ogm,ogv,wmv,m4v,mp4,mov,f4v,mkv,flv,rmvb}=$VIDEOPLAYER
alias -s {mp3,ogg,wav,flac}=$AUDIOPLAYER

# Image Aliases
alias -s {bmp,jpg,JPG,jpeg,JPEG,png,PNG,gif,GIF}=$IMGVIEWER

# Document Aliases
alias -s {odt,doc,docx,ppt,pptx,xls,xlsx,rtf}='libreoffice'
alias -s pdf=$PDFVIEWER
alias -s djvu=$DJVUVIEWER

# Interets Aliases
alias -s {html,htm,org,com,org,net}=$BROWSER
alias -s swf=$BROWSER

# Scripts
alias -s py='python'
alias -s pl='perl'

# Text Editor stuff
alias -s {txt,log}=$EDITOR

# Windows progs
#alias -s exe=wine


#######################################
# Functions

# Stuff that i should use more often
function goto() { [ -d "$1" ] && cd "$1" || cd "$(dirname "$1")"; }
function cpf() { cp "$@" && goto "$_"; }
function mvf() { mv "$@" && goto "$_"; }

function rs() { rsync -auvhP "$@" }
function touchee() { touch $2 && chmod $1 $2 }
function md() { mkdir -p "$@" && cd "$1" }

function testarchive() { 7za l "$@" }

CRYPT_EXT='3des'
function encrypt() {
        [ -e "$1" ] || return 1
        openssl des3 -salt -in "$1" -out "$1.$CRYPT_EXT"
        [ -e "$1.$CRYPT_EXT" ] && shred -u "$1"
}
function decrypt() {
        [ -e "$1" ] || return 1
        [ "${1%.$CRYPT_EXT}" != "$1" ] || return 2
        openssl des3 -d -salt -in $1 -out ${1%.$CRYPT_EXT}
        [ -e "${1%.$CRYPT_EXT}" ] && rm -f "$1"
}

confirm() {
    local answer
    echo -ne "zsh: sure you want to run '${YELLOW}$@${NC}' [yN]? "
    read -q answer
    if [[ "${answer}" =~ ^[Yy]$ ]]; then
        echo
        command "${=@}"
    elif [[ "${answer}" =~ ^[Nn]$ ]]; then
        echo
    fi
}

poweroff() {
    local runcommand
    if [ -n "${USER}" ] && [ "${USER}" != 'root' ]; then
        runcommand="sudo poweroff"
    else
        runcommand='poweroff'
    fi
    confirm "${runcommand}" "$@"
}

reboot() {
    local runcommand
    if [ -n "${USER}" ] && [ "${USER}" != 'root' ]; then
        runcommand='sudo reboot'
    else
        runcommand='reboot'
    fi
    confirm "${runcommand}" "$@"
}

downall()
{
    wget -r -l1 -H -t1 -nd -N -np -A.mp3 -erobots=off -i "$1"
}

randfile()
{
    local directory=${1:-.}
    local numFiles=${2:-1}
    find $directory -maxdepth 1 -type f | shuf -n$numFiles
}

fileswap()
{
    local a=$1
    local b=$2
    local tmpfile=$(mktemp)

    mv "$a" "$tmpfile" && mv "$b" "$a" && mv "$tmpfile" "$b"
}

function mkbackup
{
    local tag=$1
    local dir=$2
    local currentTime=$(date +%Y-%m-%d)

    tar czvf "$tag-$currentTime.tar.gz" "$dir"
}

#######################################
# Completion
autoload -U compinit
compinit

setopt COMPLETE_IN_WORD # Complete from both ends of a word.
setopt ALWAYS_TO_END # Move cursor to the end of a completed word.
setopt PATH_DIRS # Perform path search even on command names with slashes.
setopt AUTO_MENU # Show completion menu on a succesive tab press.
setopt AUTO_LIST # Automatically list choices on ambiguous completion.
setopt AUTO_PARAM_SLASH # If completed parameter is a directory, add a trailing slash.
unsetopt MENU_COMPLETE # Do not autoselect the first completion entry.
unsetopt FLOW_CONTROL # Disable start/stop characters in shell editor.

# Fuzzy Completion
#zstyle ':completion:*' completer _complete _match _approximate
#zstyle ':completion:*:match:*' original only
#zstyle ':completion:*:approximate:*' max-errors 1 numeric

#zstyle ':completion:*:functions' ignored-patterns '_*'
#zstyle :compinstall filename "$HOME/.zshrc"

# color for completion
#zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# menu for auto-completion
#zstyle ':completion:*' menu select=2
#zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
 
# Completion Menu for kill
## zstyle ':completion:*:*:kill:*' menu yes select

# Cache                                       
#zstyle ':completion::complete:*' use-cache on 
#zstyle ':completion::complete:*' cache-path ~/.config/zsh/cache

#zstyle ':completion:*' accept-exact '*(N)'

#zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
#zstyle ':completion:*' completer _expand _complete _ignored _approximate
#zstyle ':completion:*:descriptions' format '%U%F{cyan}%d%f%u'

# Treat these characters as part of a word.
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

# Use caching to make completion for cammands such as dpkg and apt usable.
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "$HOME/.zcache"

# Case-insensitive (all), partial-word, and then substring completion.
if zstyle -t ':omz:completion:*' case-sensitive; then
zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
  setopt CASE_GLOB
else
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
  unsetopt CASE_GLOB
fi

# Group matches and describe.
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# Fuzzy match mistyped completions.
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Increase the number of errors based on the length of the typed word.
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'

# Don't complete unavailable commands.
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'

# Array completion element sorting.
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Directories
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'
zstyle ':completion:*' squeeze-slashes true

# History
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

########################################
# Prompt

# mean prompt theme
# by Bryan Gilbert: https://github.com/gilbertw1/mean
#
# Based on Lean by Miek Gieben: https://github.com/miekg/lean
#   Based on Pure by Sindre Sorhus: https://github.com/sindresorhus/pure
#
# MIT License
PROMPT_MEAN_TMUX=${PROMPT_MEAN_TMUX-" t"}

# turns seconds into human readable time, 165392 => 1d 21h 56m 32s
prompt_mean_human_time() {
    local tmp=$1
    local days=$(( tmp / 60 / 60 / 24 ))
    local hours=$(( tmp / 60 / 60 % 24 ))
    local minutes=$(( tmp / 60 % 60 ))
    local seconds=$(( tmp % 60 ))
    (( $days > 0 )) && echo -n "${days}d "
    (( $hours > 0 )) && echo -n "${hours}h "
    (( $minutes > 0 )) && echo -n "${minutes}m "
    echo "${seconds}s "
}

# fastest possible way to check if repo is dirty
prompt_mean_git_dirty() {
    # check if we're in a git repo
    command git rev-parse --verify HEAD &>/dev/null || return

    git diff-files --no-ext-diff --quiet &>/dev/null && git diff-index --no-ext-diff --quiet --cached HEAD &>/dev/null
    (($? != 0)) && echo '✱'
}

# displays the exec time of the last command if set threshold was exceeded
prompt_mean_cmd_exec_time() {
    local stop=$EPOCHSECONDS
    local start=${cmd_timestamp:-$stop}
    integer elapsed=$stop-$start
    (($elapsed > ${PROMPT_LEAN_CMD_MAX_EXEC_TIME:=5})) && prompt_mean_human_time $elapsed
}

prompt_mean_preexec() {
    cmd_timestamp=$EPOCHSECONDS

    # shows the current dir and executed command in the title when a process is active
    print -Pn "\e]0;"
    echo -nE "$PWD:t: $2"
    print -Pn "\a"
}

prompt_short_pwd() {

  local short full part cur
  local first
  local -a split    # the array we loop over

  split=(${(s:/:)${(Q)${(D)1:-$PWD}}})

  if [[ $split == "" ]]; then
    print "/"
    return 0
  fi

  if [[ $split[1] = \~* ]]; then
    first=$split[1]
    full=$~split[1]
    shift split
  fi

  if (( $#split > 0 )); then
    part=/
fi

for cur ($split[1,-2]) {
  while {
           part+=$cur[1]
           cur=$cur[2,-1]
           local -a glob
           glob=( $full/$part*(-/N) )
           # continue adding if more than one directory matches or
           # the current string is . or ..
           # but stop if there are no more characters to add
           (( $#glob > 1 )) || [[ $part == (.|..) ]] && (( $#cur > 0 ))
        } { # this is a do-while loop
  }
  full+=$part$cur
  short+=$part
  part=/
}
  print "$first$short$part$split[-1]"
  return 0
}

function prompt_mean_insert_mode () { echo "-- INSERT --" }
function prompt_mean_normal_mode () { echo "-- NORMAL --" }

prompt_mean_precmd() {
    rehash

    local jobs
    local prompt_mean_jobs
    unset jobs
    for a (${(k)jobstates}) {
        j=$jobstates[$a];i="${${(@s,:,)j}[2]}"
        jobs+=($a${i//[^+-]/})
    }
    # print with [ ] and comma separated
    prompt_mean_jobs=""
    [[ -n $jobs ]] && prompt_mean_jobs="%F{242}["${(j:,:)jobs}"] "

    vcsinfo="$(git symbolic-ref --short HEAD 2>/dev/null)"
    if [[ !  -z  $vcsinfo  ]] then
        vcsinfo="%F{2}$vcsinfo%F{5}`prompt_mean_git_dirty` "
    else
        vcsinfo=" "
    fi

    case ${KEYMAP} in
      (vicmd)      
        VI_MODE="%F{blue}$(prompt_mean_normal_mode)" 
        printf "\e[3 q"
        ;;
      (main|viins) 
        VI_MODE="%F{2}$(prompt_mean_insert_mode)" 
        printf "\e[1 q"
        ;;
      (*)          
        VI_MODE="%F{2}$(prompt_mean_insert_mode)" 
        printf "\e[1 q"
        ;;
    esac

    PROMPT="$prompt_mean_jobs%F{11}$prompt_mean_tmux `prompt_mean_cmd_exec_time`%f%F{blue}`prompt_short_pwd` %(?.%F{12}.%B%F{red})❯%(?.%F{5}.%B%F{red})❯%(?.%F{13}.%B%F{red})❯%f%b "
    RPROMPT="$vcsinfo%F{12}λ$prompt_mean_host%f"

    unset cmd_timestamp # reset value since `preexec` isn't always triggered
}

prompt_mean_setup() {
    prompt_opts=(cr subst percent)

    zmodload zsh/datetime
    autoload -Uz add-zsh-hook

    add-zsh-hook precmd prompt_mean_precmd
    add-zsh-hook preexec prompt_mean_preexec

    prompt_mean_host=" %F{11}%m%f"
    [[ "$TMUX" != '' ]] && prompt_mean_tmux=$PROMPT_MEAN_TMUX
}

function zle-line-init zle-keymap-select {
    prompt_mean_precmd
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

prompt_mean_setup "$@"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then exec startx; fi
