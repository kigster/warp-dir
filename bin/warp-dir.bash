#!/usr/bin/env bash
# vim: ft=bash
#
# WarpDir (v1.7.0) shell wrapper, installed by a gem 'warp-dir'
#
# © 2012-2011, Konstantin Gredeskoul
#
# https://github.com/kigster/warp-dir
#
# shellcheck disable=SC2207,SC2206

declare -a wd_commands
declare -a wd_short_flags
declare -a wd_long_flags
declare -a wd_default_dotfiles

export wd_commands=(add ls remove warp install help list)
export wd_default_dotfiles=(~/.bash_profile ~/.bashrc ~/.bash_login ~/.profile ~/.zshrc)

function _wd::init() {
  [[ ${#wd_long_flags[@]} -gt 0 ]] && return
  command -v warp-dir >/dev/null && {
    export wd_long_flags=($(wd --help | awk 'BEGIN{FS="--"}{print "--" $2}' | sed -E '/^--$/d' | grep -E -v ']|help' | grep -E -- "${cur}" | awk '{if ($1 != "") { printf "%s\n", $1} } '))
    export wd_short_flags=($(wd --help | grep -E -- '-[a-z], --' | cut -d '-' -f 2 | tr -d ',' | sed 's/^/-/g'))
  }
}

function _wd::debug() {
  printf "%-20s: %s\n" "long flags" "$(echo "${wd_long_flags[*]}" | tr '\n' ' ')"
  printf "%-20s: %s\n" "short flags" "$(echo "${wd_short_flags[*]}" | tr '\n' ' ')"
  printf "%-20s: %s\n" "commands" "$(echo "${wd_commands[*]}" | tr '\n' ' ')"
  printf "%-20s: %s\n" "points" "$(_wd::current-points | tr '\n' ' ')"
}

function _wd::current-points() {
  warp-dir list --no-color | awk '{ print $1 }'
}

function _wd::err() {
  printf "\n\e[7;31m ERROR ❯❯  \e[0;31m %s\e[0;0m\n" "$*" >&2
}

function _wd::info() {
  printf "\n\e[7;34m INFO  ❯❯  \e[0;35m %s\e[0;0m\n" "$*" >&2
}

function _wd::exec() {
  export WARP_DIR_SHELL=yes
  export RUBYOPT="-W0"
  if type rbenv | grep -q function; then
    rbenv exec warp-dir "$@" 2>&1
  else
    warp-dir "$@"
  fi
}

function _wd::not-found() {
  _wd::err "Can't find 'warp-dir' executable!"

  printf "
  Is the gem properly installed?

  Perhaps try reinstalling the gem as shown:  \e[0;34m

    gem install warp-dir --no-wrapper
    warp-dir install --dotfile ~/.bash_profile
    hash -r
    wd -h\e[0;0m
  "
}

function wd() {
  if [[ "$1" == "--comp-debug" ]]; then
    _wd::debug
    return
  fi

  _wd::init

  local temp code
  temp="$(mktemp)"

  command -v warp-dir >/dev/null || {
    hash -r 2>/dev/null
    if [[ -z $(which warp-dir) ]]; then
      _wd::info "Can't find warp-dir executable, installing the missing gem..."
      gem install -N --quiet --force --no-wrapper warp-dir >/dev/null 2>"${temp}"
      code=$?
      hash -r 2>/dev/null
      if [[ ${code} -eq 0 ]]; then
        _wd::info "Installation was successful, warp-dir executable is now at:"
        _wd::info "\e[1;32m$(which warp-dir)"
        _wd::init
      else
        _wd::err "Install failed, exit code=${code}\n"
        [[ -s "${temp}" ]] && {
          printf "\e[1;31m"
          cat "${temp}"
          printf "\e[0;0m"
        }
      fi
    fi
  }

  command -v warp-dir >/dev/null || {
    _wd::err "Can't find warp-dir executable in the PATH" && return 1
  }

  local previous_ifs=$IFS
  IFS="+"

  local output
  set +e
  output="$(_wd::exec "$@")"
  local code=$?

  if [[ $code -eq 127 ]]; then
    [[ -n $(command -v rbenv) ]] && rbenv rehash >/dev/null 2>&1
    output="$(_wd::exec "$@")"
    code=$?
    if [[ $code -eq 127 ]]; then
      _wd::not-found
      export IFS="${previous_ifs}"
      return 1
    fi
  fi

  eval "${output}"
  export IFS="${previous_ifs}"
}

# @description Command Completion
#
# COMP_WORDS: an array of all the words typed after the name of the program
#             the compspec belongs to
#
# COMP_CWORD: an index of the COMP_WORDS array pointing to the word the current
#             cursor is at—in other words, the index of the word the cursor was
#             when the tab key was pressed
#
# COMP_LINE:  the current command line
#
# suggestions:  The contents of the suggestions variable are
#             always displayed. The function is now
#             responsible for adding or removing entries from
#             there. If the suggestions variable had only one
#             element, then that word would be automatically
#             completed in the command.
#
#             Enter compgen: builtin command that generates completions
#             supporting most of the options of the complete command
#             generator (ex. -W for word list, -d for directories) and
#             filtering them based on what the user has already typed.
function _wd_completions() {
  _wd::init

  if [[ "${#COMP_WORDS[@]}" -lt 2 ]]; then
    return
  fi

  local -a wd_points=($(_wd::current-points))
  local -a suggestions=()

  local cur="${COMP_WORDS[${COMP_CWORD}]}"
  local prev="${COMP_WORDS[$((COMP_CWORD - 1))]}"

  if [[ ${cur} == --* ]]; then
    suggestions+=(${wd_long_flags[@]})
  elif [[ ${cur} == -* ]]; then
    suggestions+=(${wd_short_flags[@]})
  elif [[ ${COMP_CWORD} -gt 1 ]]; then
    suggestions+=(${wd_short_flags[@]})
    suggestions+=(${wd_long_flags[@]})
  else
    suggestions+=(${wd_points[@]})
    suggestions+=(${wd_commands[@]})
  fi

  suggestions=($(compgen -W "${suggestions[*]}" -- "${cur}"))

  if [[ "${prev}" == wd ]]; then
    suggestions+=($(compgen -d -- "${cur}"))

  elif [[ "${prev}" == "--dotfile" ]]; then
    local -a inits

    for file in "${wd_default_dotfiles[@]}"; do
      [[ -s "${file}" ]] && inits+=("${file}")
    done

    case "${cur}" in
    [a-z]*)
      cur="${HOME}/.${cur}"
      ;;
    .[a-z]*)
      cur="${HOME}/${cur}"
      ;;
    esac
    suggestions=($(compgen -W "${inits[*]}" -- "${cur}"))
  fi

  if [[ "${#suggestions[@]}" -eq 1 ]]; then
    COMPREPLY=("${suggestions[0]}")
  else
    COMPREPLY=(${suggestions[@]})
  fi
}

complete -F _wd_completions wd
