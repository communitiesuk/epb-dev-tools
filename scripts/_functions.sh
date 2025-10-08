#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
POSTGRES_VERSION=17.5

pull_application() {
  CLONE_URL=$1
  CLONE_DIR="$(get_parent_directory)/$(get_name_from_git_uri "$CLONE_URL")"

  echo -e "Checking directory $CLONE_DIR\n"

  if [[ -d $CLONE_DIR ]]; then
    echo -e "Pulling git repo at $CLONE_DIR\n"
    ORIGIN_DIR=$PWD

    cd "$CLONE_DIR" || exit 1
    git pull
    cd "$ORIGIN_DIR" || exit 1
  else
    echo -e "Cloning git repo at $CLONE_DIR\n"
    git clone "$CLONE_URL" "$CLONE_DIR"
  fi
}

clone_application() {
  HELP_TEXT=$1
  CLONE_URL=$2
  CLONE_DIR="$(get_parent_directory)/$(get_name_from_git_uri "$CLONE_URL")"

  printf "%s\n" "$HELP_TEXT"

  CODEBASE_PATH="$CLONE_DIR"

  if [[ ! -d $CODEBASE_PATH ]]; then
    echo -e "Cloning into local directory $CODEBASE_PATH\n"
    git clone "$CLONE_URL" "$CLONE_DIR"
  else
    echo -e "Directory $CODEBASE_PATH already exists, continuing\n"
  fi

  if [[ -z $CODEBASE_PATH ]]; then
    echo -e "\nCancelling setup\n"
    exit 1
  fi

  export CODEBASE_PATH=$CODEBASE_PATH
}

confirm() {
  HELP_TEXT=$1

  if [[ "$OVERRIDE_CONFIRM" == "true" ]]; then
    echo "Overriding confirmation for $HELP_TEXT"
    CONFIRMED=1
    echo $CONFIRMED

  else
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

  fi
}

join() {
  local IFS="$1"
  shift
  echo "$*"
}

get_name_from_git_uri() {
  CLONE_URL=$1
  IFS='/' read -ra CODE_DIR <<<"$CLONE_URL"
  CODE_DIR="${CODE_DIR[${#CODE_DIR[@]}-1]}"
  echo "${CODE_DIR/.git/}"
}

get_parent_directory() {
  IFS='/' read -ra CODE_DIR <<<"$PWD"
  unset 'CODE_DIR[${#CODE_DIR[@]}-1]'
  # shellcheck disable=SC2068
  echo "/$(join / ${CODE_DIR[@]})"
}

generate_template() {
  rm -r docker-compose.yml 2>/dev/null

  SUBSTITUTE_VARS='\
    ${EPB_ADDRESSING_PATH},\
    ${EPB_AUTH_SERVER_PATH},\
    ${EPB_DATA_FRONTEND_PATH},\
    ${EPB_DATA_WAREHOUSE_PATH},\
    ${EPB_FRONTEND_PATH},\
    ${EPB_REGISTER_API_PATH},\
    ${POSTGRES_VERSION},\
    ${PWD}\
  '

  POSTGRES_VERSION=$POSTGRES_VERSION \
  envsubst "$SUBSTITUTE_VARS" < docker-compose.template.yml > docker-compose.yml
}

setup_hostsfile() {
  HOSTS_LINE="127.0.0.1 epb-data-frontend getting-new-energy-certificate.epb-frontend find-energy-certificate.epb-frontend getting-new-energy-certificate.local.gov.uk find-energy-certificate.local.gov.uk epb-frontend epb-register-api epb-auth-server epb-feature-flag epb-data-warehouse-api one-login-simulator"

  if grep -q "$HOSTS_LINE" "/etc/hosts"; then
    echo "Hostsfile configuration already there"
  else
    echo "Injecting hostsfile configuration"
    echo "$HOSTS_LINE" | sudo tee -a /etc/hosts
  fi
}

setup_bash_profile() {
  ALIAS_INFO="alias epb=\"$DIR/../epb\""

  if [[ -f "$HOME/.zshrc" ]]; then
    if [[ -n $(confirm "Add epb to profile at ~/.zshrc?") ]]; then
      if grep -q "$ALIAS_INFO" "$HOME/.zshrc"; then
        # shellcheck disable=SC2088
        echo "~/.zshrc already has the line $ALIAS_INFO"
      else
        echo "Injecting into ~/.zshrc, run source ~/.zshrc to use the command"
        echo "$ALIAS_INFO" | tee -a ~/.zshrc
      fi
    fi
  fi

  if [[ -f "$HOME/.bash_profile" ]]; then
    if [[ -n $(confirm "Add epb to profile at ~/.bash_profile?") ]]; then
      if grep -q "$ALIAS_INFO" "$HOME/.bash_profile"; then
        # shellcheck disable=SC2088
        echo "~/.bash_profile already has the line $ALIAS_INFO"
      else
        echo "Injecting into ~/.bash_profile, run source ~/.bash_profile to use the command"
        echo "$ALIAS_INFO" | tee -a ~/.bash_profile
      fi
    fi
  fi

}

until_accepting_connections() {
  CONTAINER_NAME=$1
  until docker run --rm --network epb-dev-tools_default --link "$CONTAINER_NAME:pg" postgres:$POSTGRES_VERSION pg_isready -U postgres -h pg; do sleep 1; done
}

generate_tls_keys(){
  KEYS_DIR="./keys"
  ENV_FILE="./.env.keys"
  mkdir -p "$KEYS_DIR"

  # Generate RSA private key
  PRIVATE_KEY_FILE="$KEYS_DIR/private_key.pem"
  PUBLIC_KEY_FILE="$KEYS_DIR/public_key.pem"
  JSON_KEY_FILE="$KEYS_DIR/onelogin_tls_keys.json"
  KID="kid-$(date +%s)" # Simple unique key id

  if [ ! -f "$PRIVATE_KEY_FILE" ]; then
    echo "Generating RSA keypair..."
    openssl genpkey -algorithm RSA -out "$PRIVATE_KEY_FILE" -pkeyopt rsa_keygen_bits:2048
    openssl rsa -pubout -in "$PRIVATE_KEY_FILE" -out "$PUBLIC_KEY_FILE"
  else
    echo "RSA keypair already exists, skipping generation."
  fi

  # Read keys into variables (escaped for JSON)
  PRIVATE_KEY_ESCAPED=$(awk '{printf "%s\\n", $0}' "$PRIVATE_KEY_FILE")
  PUBLIC_KEY_ESCAPED=$(awk '{printf "%s\\n", $0}' "$PUBLIC_KEY_FILE")

  # Create JSON structure and escape
  TLS_KEYS_JSON=$(cat <<EOF
{
  "kid": "$KID",
  "private_key": "$PRIVATE_KEY_ESCAPED",
  "public_key": "$PUBLIC_KEY_ESCAPED"
}
EOF
  )
  TLS_KEYS_JSON_ESCAPED=$(echo "$TLS_KEYS_JSON" | tr -d '\n' | sed -E 's/[[:space:]]+/ /g' | sed 's/  */ /g')


  # Write .env.keys
  echo "Writing to $ENV_FILE"
  cat > "$ENV_FILE" <<EOF
# Auto-generated
PUBLIC_KEY="$PUBLIC_KEY_ESCAPED"
ONELOGIN_TLS_KEYS='$TLS_KEYS_JSON_ESCAPED'
EOF

  echo "Keys written to $KEYS_DIR:"
  echo "  - Private key: $PRIVATE_KEY_FILE"
  echo "  - Public key:  $PUBLIC_KEY_FILE"
  echo "  - JSON keys:   $JSON_KEY_FILE"
}
