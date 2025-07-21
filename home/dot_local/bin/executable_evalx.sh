#!/usr/bin/env zsh
# shellcheck disable=SC1090,SC1091

typeset -A __evalx_options

function __evalx_set_function() {
  function __evalx_blink_cursor() {
    echo '\e[5 q'
  }

  function __evalx_clean_flatpak() {
    flatpak uninstall --unused
  }

  function __evalx_clean_pacman() {
    sudo pacman -Scc
  }

  function __evalx_create_python_venv() {
    python -m venv .venv
  }

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

  function __evalx_git_fetch_prune() {
    git fetch --prune
  }

  function __evalx_pacman_log() {
    bat /var/log/pacman.log
  }

  function __evalx_restart_kanata_service() {
    systemctl --user restart kanata.service
  }

  function __evalx_source_Hyde_completion() {
    source Hyde.zsh
  }

  function __evalx_source_chezmoi_completion() {
    source <(chezmoi completion zsh)
  }

  function __evalx_source_docker_completion() {
    source <(docker completion zsh)
  }

  function __evalx_source_just_completion() {
    echo good
    source <(just --completions zsh)
  }

  function __evalx_source_k3s_completion() {
    source <(k3s completion zsh)
  }

  function __evalx_source_kubectl_completion() {
    source <(kubectl completion zsh)
  }

  function __evalx_source_npm_completion() {
    source <(npm completion)
  }

  function __evalx_source_python_venv() {
    source .venv/bin/activate
  }

  function __evalx_source_railway_completion() {
    source <(railway completion zsh)
  }

  function __evalx_source_warp_cli_completion() {
    source <(warp-cli generate-completions zsh)
  }

  function __evalx_start_docker_desktop_service() {
    systemctl --user start docker-desktop
  }

  function __evalx_start_docker_service() {
    sudo systemctl start docker.service docker.socket
  }

  function __evalx_start_k3s_agent_service() {
    sudo systemctl start k3s-agent.service
  }

  function __evalx_start_k3s_service() {
    sudo systemctl start k3s.service
  }

  function __evalx_start_libvirtd_service() {
    sudo systemctl start libvirtd.service
  }

  function __evalx_start_mysql_service() {
    sudo systemctl start mysqld.service
  }

  function __evalx_start_ssh_agent() {
    eval "$(ssh-agent -s)"
  }

  function __evalx_start_sshd_service() {
    sudo systemctl start sshd.service
  }

  function __evalx_start_tailscale_service() {
    sudo systemctl start tailscaled.service
  }

  function __evalx_stop_docker_desktop_service() {
    systemctl --user stop docker-desktop
  }

  function __evalx_stop_docker_service() {
    sudo systemctl stop docker.service docker.socket
  }

  function __evalx_stop_k3s_agent_service() {
    sudo systemctl stop k3s-agent.service
  }

  function __evalx_stop_k3s_service() {
    sudo systemctl stop k3s.service
  }

  function __evalx_stop_libvirtd_service() {
    sudo systemctl stop libvirtd.service
  }

  function __evalx_stop_mysql_service() {
    sudo systemctl stop mysqld.service
  }

  function __evalx_stop_sshd_service() {
    sudo systemctl stop sshd.service
  }

  function __evalx_stop_tailscale_service() {
    sudo systemctl stop tailscaled.service
  }
}

function __evalx_set_options() {
  __evalx_options['change to blink cursor']='__evalx_blink_cursor'
  __evalx_options['clean flatpak']='__evalx_clean_flatpak'
  __evalx_options['clean pacman']='__evalx_clean_pacman'
  __evalx_options['create python venv']='__evalx_create_python_venv'
  __evalx_options['echo key press']='__evalx_echo_key_press'
  __evalx_options['get my ip']='__evalx_get_my_ip'
  __evalx_options['git clean repo']='__evalx_git_clean_repo'
  __evalx_options['git fetch prune']='__evalx_git_fetch_prune'
  __evalx_options['pacman log']='__evalx_pacman_log'
  __evalx_options['restart kanata service']='__evalx_restart_kanata_service'
  __evalx_options['source Hyde completion']='__evalx_source_Hyde_completion'
  __evalx_options['source chezmoi completion']='__evalx_source_chezmoi_completion'
  __evalx_options['source docker completion']='__evalx_source_docker_completion'
  __evalx_options['source just completion']='__evalx_source_just_completion'
  __evalx_options['source k3s completion']='__evalx_source_k3s_completion'
  __evalx_options['source kubectl completion']='__evalx_source_kubectl_completion'
  __evalx_options['source npm completion']='__evalx_source_npm_completion'
  __evalx_options['source python venv']='__evalx_source_python_venv'
  __evalx_options['source railway completion']='__evalx_source_railway_completion'
  __evalx_options['source warp cli completion']='__evalx_source_warp_cli_completion'
  __evalx_options['start docker desktop service']='__evalx_start_docker_desktop_service'
  __evalx_options['start docker service']='__evalx_start_docker_service'
  __evalx_options['start k3s agent service']='__evalx_start_k3s_agent_service'
  __evalx_options['start k3s service']='__evalx_start_k3s_service'
  __evalx_options['start libvirtd service']='__evalx_start_libvirtd_service'
  __evalx_options['start mysql service']='__evalx_start_mysql_service'
  __evalx_options['start ssh agent']='__evalx_start_ssh_agent'
  __evalx_options['start sshd service']='__evalx_start_sshd_service'
  __evalx_options['start tailscale service']='__evalx_start_tailscale_service'
  __evalx_options['stop docker desktop service']='__evalx_stop_docker_desktop_service'
  __evalx_options['stop docker service']='__evalx_stop_docker_service'
  __evalx_options['stop k3s agent service']='__evalx_stop_k3s_agent_service'
  __evalx_options['stop k3s service']='__evalx_stop_k3s_service'
  __evalx_options['stop libvirtd service']='__evalx_stop_libvirtd_service'
  __evalx_options['stop mysql service']='__evalx_stop_mysql_service'
  __evalx_options['stop sshd service']='__evalx_stop_sshd_service'
  __evalx_options['stop tailscale service']='__evalx_stop_tailscale_service'

}

# ${__evalx_options['source Hyde completion']}
# echo ${__evalx_options['source Hyde completion']}
# ${options["source just completion"]}

function __evalx_main() {
  local -a commands
  commands=$(
    printf "%s\n" "${(@kQ)__evalx_options}" | fzf \
      --multi \
      --no-sort \
      --with-shell='zsh -c' \
      --preview-window='down,border-top' \
      --preview='set -- -s; source evalx.sh; functions ${__evalx_options[{}]} | bat --color=always --language=zsh --style=plain'
  )

  printf "%s\n" "${commands[@]}" | while read -r command; do
    ${__evalx_options[${(qq)command}]}
  done
}

function __evalx_clean() {
  for fun in "${__evalx_options[@]}"; do
    unfunction "$fun"
  done
  unfunction __evalx_source
  unfunction __evalx_main
  unfunction __evalx_clean
}

case "$1" in
  "-s" | "--source" )
    __evalx_set_function
    __evalx_set_options
    ;;
  *)
    __evalx_set_function
    __evalx_set_options
    __evalx_main
    __evalx_clean
    unset __evalx_options
    ;;
esac
