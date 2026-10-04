function azgs() {
  az account show --output tsv --query 'name' 2>/dev/null
}

alias azss="az account set --subscription"

function az_subscriptions() {
  local profile="${AZURE_CONFIG_DIR:-$HOME/.azure}/azureProfile.json"
  if (( $+commands[jq] )) && [[ -r "$profile" ]]; then
    jq -r '.subscriptions[].name' "$profile" 2>/dev/null && return
  fi
  az account list --all --output tsv --query '[*].name' 2>/dev/null
}

function _az_subscriptions() {
  reply=("${(@f)$(az_subscriptions)}")
}
compctl -K _az_subscriptions azss

function azure_prompt_info() {
  [[ ! -f "${AZURE_CONFIG_DIR:-$HOME/.azure}/azureProfile.json" ]] && return
  (( $+commands[jq] )) || return 1
  azgs=$(jq -r '.subscriptions[] | select(.isDefault==true) .name' "${AZURE_CONFIG_DIR:-$HOME/.azure}/azureProfile.json")
  echo "${ZSH_THEME_AZURE_PREFIX:=<az:}${azgs}${ZSH_THEME_AZURE_SUFFIX:=>}"
}

if (( $+commands[az] )); then
  for _az_completion in \
    "${commands[az]:A:h}/az.completion.sh" \
    /usr/share/bash-completion/completions/az \
    /etc/bash_completion.d/azure-cli \
    ${commands[brew]:+${commands[brew]:h:h}/etc/bash_completion.d/az}; do
    if [[ -r "$_az_completion" ]]; then
      autoload -U +X bashcompinit && bashcompinit
      source "$_az_completion"
      break
    fi
  done
  unset _az_completion
fi
