#!/usr/bin/env bash

clone_application() {
  HELP_TEXT=$1
  CLONE_URL=$2
  CLONE_DIR="$(get_parent_directory)/$(get_name_from_git_uri "$CLONE_URL")"

  printf "%s\n" "$HELP_TEXT"

  if [[ -z $(confirm "Clone to $CLONE_DIR?") ]]; then
    CODEBASE_PATH=""
  else
    CODEBASE_PATH="$CLONE_DIR"

    if [[ ! -d $CODEBASE_PATH ]]; then
      echo -e "Cloning into local directory $CODEBASE_PATH\n"
      git clone "$CLONE_URL" "$CLONE_DIR"
    else
      echo -e "Directory already exists, continuing\n"
    fi
  fi

  if [[ -z $CODEBASE_PATH ]]; then
    echo -e "\nCancelling setup\n"
    exit 1
  fi

  export CODEBASE_PATH=$CODEBASE_PATH
}

confirm() {
  HELP_TEXT=$1
  while true; do
    read -rp "$HELP_TEXT [y/N] " CONFIRMATION
    case $CONFIRMATION in
    [Yy]*)
      CONFIRMED=1
      break
      ;;
    *)
      break
      ;;
    esac
  done
  echo $CONFIRMED
}

join() {
  local IFS="$1"
  shift
  echo "$*"
}

get_name_from_git_uri() {
  CLONE_URL=$1
  IFS='/' read -ra CODE_DIR <<<"$CLONE_URL"
  CODE_DIR="${CODE_DIR[1]}"
  echo "${CODE_DIR/.git/}"
}

get_parent_directory() {
  IFS='/' read -ra CODE_DIR <<<"$PWD"
  unset 'CODE_DIR[${#CODE_DIR[@]}-1]'
  # shellcheck disable=SC2068
  echo "/$(join / ${CODE_DIR[@]})"
}
