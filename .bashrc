export BASH_SILENCE_DEPRECATION_WARNING=1

# Put Homebrew paths ahead of all the other paths.
export PATH=/usr/local/bin:/usr/local/sbin:$PATH

# Fix terminal colours.
# export CLICOLOR=1
# export LSCOLORS=GxFxCxDxBxegedabagaced

# Add colours to grep.
export GREP_OPTIONS='--color=auto'

# Enable bash autocompletion for Git.
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Modify the prompt.
PS1='\u@\h \w$(parse_git_branch)> '

# Enable pyenv
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

if command -v nodenv 1>/dev/null 2>&1; then
  eval "$(nodenv init -)"
fi

# Enable rbenv shims and autocompletion.
if which rbenv > /dev/null; then
  export RBENV_ROOT=/usr/local/var/rbenv
  eval "$(rbenv init -)";
fi

if which heroku > /dev/null; then
  heroku autocomplete:script bash 1>/dev/null
fi

#---------
# Aliases
#---------

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ..='cd ..'

alias gs='git status'
alias gsu='git status -uno'
alias gd='git diff'
alias gdc='git diff --cached'
alias gc='git commit -m'
alias ga='git commit --amend'
alias gl='git log'
alias gsl='git stash list'
alias gsp='git stash pop'
alias gsa='git stash apply'
alias gspk='git stash show -p'
alias gpsf='git push --force'
alias gps='git push'
alias gpl='git pull'
alias gplrm='git pull --rebase origin master'

#------------------
# Custom functions
#-----------------

draft () {
  open "$(git remote get-url --push origin | awk -F '\\.git' '{print $1}')/pull/new/$(git rev-parse --abbrev-ref HEAD)"
}

dbmigrate() {
  bin/rake db:migrate db:test:prepare
}

dbrollback() {
  bin/rake db:rollback
}

prune() {
  for branch in "$@"; do git br -D "$branch" && git push origin :"$branch"; done
}

pruneall() {
  git br -r | awk -F/ '/\/lerebear-/{print $2}'

  read -p "Prune the listed branches (Y/n)? " -n 1 -r
  echo # Move to new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    git br -r | awk -F/ '/\/lerebear-/{print $2}' | xargs -I {} git br -D {}; git push origin :{}
  fi
}
