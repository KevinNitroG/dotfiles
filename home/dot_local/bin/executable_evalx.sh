#!/usr/bin/env zsh
# shellcheck disable=SC1090,SC1091
#
# Intended to be sourced (see `ev` alias in .zshrc), not executed.
# `evalx.sh -s` / `--source` only defines the functions below and the
# __evalx_options map, used by the fzf preview subshell to look up a
# command's body without re-running fzf.

function __evalx_change_to_blink_cursor() { printf '\e[5 q'; }
function __evalx_clean_flatpak() { flatpak uninstall --unused; }
function __evalx_clean_pacman() { sudo pacman -Scc; }
function __evalx_create_python_venv() { python -m venv .venv; }
function __evalx_echo_key_press() {
  read -k -r 1
  echo
}
function __evalx_get_my_ip() {
  curl http://ifconfig.me/ip
  echo
}
function __evalx_git_clean_repo() {
  git reflog expire --expire=now --all
  git gc --prune=now --aggressive
}
function __evalx_git_fetch_prune() { git fetch --prune; }
function __evalx_pacman_log() { bat /var/log/pacman.log; }
function __evalx_restart_kanata_service() { systemctl --user restart kanata.service; }
function __evalx_source_hyde_completion() { source Hyde.zsh; }
function __evalx_source_chezmoi_completion() { source <(chezmoi completion zsh); }
function __evalx_source_docker_completion() { source <(docker completion zsh); }
function __evalx_source_just_completion() { source <(just --completions zsh); }
function __evalx_source_k3s_completion() { source <(k3s completion zsh); }
function __evalx_source_kubectl_completion() { source <(kubectl completion zsh); }
function __evalx_source_mc_completion() { complete -o nospace -C mc mc; }
function __evalx_source_npm_completion() { source <(npm completion); }
function __evalx_source_python_venv() { source .venv/bin/activate; }
function __evalx_source_railway_completion() { source <(railway completion zsh); }
function __evalx_source_rc_completion() { source <(rc completions zsh); }
function __evalx_source_warp_cli_completion() { source <(warp-cli generate-completions zsh); }
function __evalx_start_docker_desktop_service() { systemctl --user start docker-desktop; }
function __evalx_start_docker_service() { sudo systemctl start docker.service docker.socket; }
function __evalx_start_k3s_agent_service() { sudo systemctl start k3s-agent.service; }
function __evalx_start_k3s_service() { sudo systemctl start k3s.service; }
function __evalx_start_libvirtd_service() { sudo systemctl start libvirtd.service; }
function __evalx_start_mysql_service() { sudo systemctl start mysqld.service; }
function __evalx_start_ssh_agent() { eval "$(ssh-agent -s)"; }
function __evalx_start_sshd_service() { sudo systemctl start sshd.service; }
function __evalx_start_tailscale_service() { sudo systemctl start tailscaled.service; }
function __evalx_stop_docker_desktop_service() { systemctl --user stop docker-desktop; }
function __evalx_stop_docker_service() { sudo systemctl stop docker.service docker.socket; }
function __evalx_stop_k3s_agent_service() { sudo systemctl stop k3s-agent.service; }
function __evalx_stop_k3s_service() { sudo systemctl stop k3s.service; }
function __evalx_stop_libvirtd_service() { sudo systemctl stop libvirtd.service; }
function __evalx_stop_mysql_service() { sudo systemctl stop mysqld.service; }
function __evalx_stop_sshd_service() { sudo systemctl stop sshd.service; }
function __evalx_stop_tailscale_service() { sudo systemctl stop tailscaled.service; }

typeset -gA __evalx_options=(
  'change to blink cursor'        __evalx_change_to_blink_cursor
  'clean flatpak'                 __evalx_clean_flatpak
  'clean pacman'                  __evalx_clean_pacman
  'create python venv'            __evalx_create_python_venv
  'echo key press'                __evalx_echo_key_press
  'get my ip'                     __evalx_get_my_ip
  'git clean repo'                __evalx_git_clean_repo
  'git fetch prune'               __evalx_git_fetch_prune
  'pacman log'                    __evalx_pacman_log
  'restart kanata service'        __evalx_restart_kanata_service
  'source Hyde completion'        __evalx_source_hyde_completion
  'source chezmoi completion'     __evalx_source_chezmoi_completion
  'source docker completion'      __evalx_source_docker_completion
  'source just completion'        __evalx_source_just_completion
  'source k3s completion'         __evalx_source_k3s_completion
  'source kubectl completion'     __evalx_source_kubectl_completion
  'source mc completion'          __evalx_source_mc_completion
  'source npm completion'         __evalx_source_npm_completion
  'source python venv'            __evalx_source_python_venv
  'source railway completion'     __evalx_source_railway_completion
  'source rc completion'          __evalx_source_rc_completion
  'source warp cli completion'    __evalx_source_warp_cli_completion
  'start docker desktop service'  __evalx_start_docker_desktop_service
  'start docker service'          __evalx_start_docker_service
  'start k3s agent service'       __evalx_start_k3s_agent_service
  'start k3s service'             __evalx_start_k3s_service
  'start libvirtd service'        __evalx_start_libvirtd_service
  'start mysql service'           __evalx_start_mysql_service
  'start ssh agent'               __evalx_start_ssh_agent
  'start sshd service'            __evalx_start_sshd_service
  'start tailscale service'       __evalx_start_tailscale_service
  'stop docker desktop service'   __evalx_stop_docker_desktop_service
  'stop docker service'           __evalx_stop_docker_service
  'stop k3s agent service'        __evalx_stop_k3s_agent_service
  'stop k3s service'              __evalx_stop_k3s_service
  'stop libvirtd service'         __evalx_stop_libvirtd_service
  'stop mysql service'            __evalx_stop_mysql_service
  'stop sshd service'             __evalx_stop_sshd_service
  'stop tailscale service'        __evalx_stop_tailscale_service
)

function __evalx_run() {
  local -a selected
  selected=("${(@f)$(
    printf '%s\n' "${(@k)__evalx_options}" | sort | fzf \
      --multi \
      --no-sort \
      --with-shell='zsh -c' \
      --preview-window='down,border-top' \
      --preview='source evalx.sh -s; k={}; functions ${__evalx_options[$k]} | bat --color=always --language=zsh --style=plain'
  )}")

  local choice
  for choice in "${selected[@]}"; do
    [[ -n "$choice" ]] && "${__evalx_options[$choice]}"
  done
}

function __evalx_cleanup() {
  local fn
  for fn in "${(@v)__evalx_options}" __evalx_run __evalx_cleanup; do
    unfunction "$fn" 2>/dev/null
  done
  unset __evalx_options
}

case "$1" in
  "-s" | "--source" )
    ;;
  *)
    __evalx_run
    __evalx_cleanup
    ;;
esac
