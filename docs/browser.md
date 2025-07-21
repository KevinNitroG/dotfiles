### Flags

```
brave://flags/#smooth-scrolling
```

```
brave://flags/#overlay-scrollbars
```

```
brave://flags/#enable-quic
```

```
brave://flags/#fluent-overlay-scrollbars
```

```
brave://flags/#fluent-scrollbars
```

```
brave://flags/#enable-tls13-early-data
```

```
brave://flags/#enable-tls13-kyber
```

```
brave://flags/#tab-groups-save-v2
```

```
brave://flags/#omit-cors-client-cert
```

```
brave://flags/#linked-services-setting
```

### Custom filters list

#### Lists

```
https://abpvn.com/vip/kev.txt?ublock
```

```
https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.txt
```

```
https://raw.githubusercontent.com/bogachenko/fuckfuckadblock/master/fuckfuckadblock.txt?_=rawlist
```

```
https://raw.githubusercontent.com/bogachenko/fuckfuckadblock/master/fuckfuckadblock-mining.txt?_=rawlist
```

#### Mine

```
! 2023-05-04 https://www.youtube.com for removing dark gradient in top of player
www.youtube.com##.ytp-gradient-top.style-scope.ytd-player
www.youtube.com##.ytp-chrome-top.style-scope.ytd-player
www.youtube.com##.ytp-big-mode.ytp-gradient-top
www.youtube.com##.ytp-gradient-top
www.youtube.com##.ytp-gradient-bottom

! youtube short block
! youtube.com###endpoint:has-text(Shorts)
! youtube.com##ytd-rich-section-renderer:has(#title:has-text(Shorts))s

! 2024-01-27 https://chat.zalo.me
chat.zalo.me##.snack-body
chat.zalo.me##.tds-banner-download__container

! Remove Youtube channel icon
www.youtube.com##.iv-branding
www.youtube.com###movie_player > div.ytp-chrome-top > div.ytp-chrome-top-buttons > button.ytp-button.ytp-share-button.ytp-share-button-visible
```
