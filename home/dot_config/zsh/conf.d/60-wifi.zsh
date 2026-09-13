# NetworkManager wifi helpers.
# Source: https://gist.github.com/guyzmo/146423d0cf7d3c0a46e10eeb66883905

connect_wifi() {
  local ssid
  local conn

  nmcli device wifi rescan >/dev/null
  ssid=$(nmcli device wifi list | tail -n +2 | grep -v '^  *\B--\B' | fzf -m | sed 's/^ *\*//' | awk '{print $1}')

  if [ "x$ssid" != "x" ]; then
    # check if the SSID has already a connection setup
    conn=$(nmcli con | grep "$ssid" | awk '{print $1}' | uniq)
    if [ "x$conn" = "x$ssid" ]; then
      echo "Please wait while switching to known network $ssid…"
      nmcli con up id "$conn"
    else
      echo "Please wait while connecting to new network $ssid…"
      nmcli device wifi connect "$ssid"
    fi
  fi
}

get_current_wifi_password() {
  nmcli device wifi show-password
}

get_wifi_password() {
  local ssid
  ssid=$(nmcli --colors=no --fields=NAME --terse connection show |
    fzf --preview='nmcli -s -g 802-11-wireless-security.psk connection show {} || echo "Cannot get password!"' \
        --preview-window='right,70%,border-left'
  )

  if [[ -z "$ssid" ]]; then
    echo "No SSID was selected!"
    return
  fi
  local password=$(nmcli -s -g 802-11-wireless-security.psk connection show $ssid)
  echo "SSID: $ssid"
  echo "PASSWORD: $password"
}
