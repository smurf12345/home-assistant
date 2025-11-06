#!/bin/bash

# Disable screen blanking
xset s off
xset -dpms
xset s noblank

# Optionally hide the mouse cursor
unclutter -idle 0 &

# Virtual Keyboard
onboard &

check_network() {
    while ! nc -z -w 5 192.168.17.11 8123; do
        echo "Checking if Home Assistant is reachable..."
        sleep 2
    done
}

check_network
echo "Home Assistant is reachable. Starting Chromium..."

chromium     --noerrdialogs     --disable-infobars     --kiosk     --disable-session-crashed-bubble    
 --disable-features=TranslateUI     --overscroll-history-navigation=0     --pull-to-refresh=2   --enabl
e-features=OverlayScrollbar,OverlayScrollbarFlashAfterAnyScrollUpdate,OverlayScrollbarFlashWhenMouseEnt
er  "https://<fqdn>/dashboard-wallboard"
#chromium     --noerrdialogs     --disable-infobars     --kiosk     --disable-session-crashed-bubble   
  --disable-features=TranslateUI     --overscroll-history-navigation=0     --pull-to-refresh=2   --enab
le-features=OverlayScr
#chromium     --noerrdialogs       --disable-session-crashed-bubble     --disable-features=TranslateUI 
    --overscroll-history-navigation=0     --pull-to-refresh=2   --enable-features=OverlayScrollbar,Over
layScrollbarFlashAfterAnyScrollUpdate,OverlayScrollbarFlashWhenMouseEnter  "http://192.168.17.11:8123/d
ashboard-wallboard"

