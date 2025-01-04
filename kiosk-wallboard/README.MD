# Home-Assistant In-Wall Touchscreen Dashboard

<img width="600" alt="image" src="https://github.com/user-attachments/assets/d782f108-0ca8-4751-bc8d-bd8eac932f9c">

## Hardware
* Elo Touch 2703LM (E125114) 27" 1080p Full Touchscreen LED LCD Monitor
* Beelink Mini S12 Pro Mini PC

## Integrations
* ~~Hass.Agent ([Hass.Agent](https://github.com/LAB02-Research/HASS.Agent-Integration)) - Allows Home-Assistant to control remote computer, send notifications, creates sensors for computer, etc.  Currently using it to put the monitor to sleep and wake the screen based motion detected in the Kitchen area.~~
* Wallpanel ([lovelace-wallpanel](https://github.com/j-a-n/lovelace-wallpanel)) - Screensaver/slideshow for when screen is not in use.  Great for displaying digital art.
* Lovelace Card Mod ([lovelace-card-mod](https://github.com/thomasloven/lovelace-card-mod)) - Allows for fine tuning CSS layout
* Week Planner Card ([week-planner-card](https://github.com/FamousWolf/week-planner-card)) - Calendar Events
* Browswer_mod ([hass-browser_mod](https://github.com/thomasloven/hass-browser_mod)) - Allow Home-Assistant to control remote browsers

## Mods
* Make toolbar at top transparent by adding to themes<br>
`   app-header-background-color: "transparent"`  
`   app-header-text-color: "white"`

## ~~Windows 11~~
~~Note: Windows ended up sitting at 90-100% CPU with one video feed on a N100 processor.  Abandoned Windows in favor Linux at reduced this to 45-50%~~
* ~~Chrome Browser Full Screen At Startup~~
* ~~Modify Chrome shortcut: "C:\Program Files\Google\Chrome\Application\chrome_proxy.exe" <ha url here> --start-fullscreen~~
* ~~Copy short cut to Windows startup folder: "C:\Users\<user here>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"~~
* ~~For now, not using Windows kiosk mode / assigned as it is too locked down.~~

## ~~Ubuntu Desktop 24.04~~
~~Note: Abandoned this for Debian without desktop environment for simplicity and low overhead.~~
* ~~Need to figure out a good way around unlocking the keychain when using autologin.  This prevents remote access where it can't open up the encrypted~~ password for remote access and generates a random new one very time it boots.  TBD...
* ~~Enable autologin~~
* ~~Firefox Full Screen Kiosk Mode at Startup~~
* ~~Go-Hass-Agent App (similar to HASS.Agent) - Provides sensors and controls to Home-Assistant. Add to Startup Apps with custom entry (~/.config/autostart/ go-hass-agent.desktop)~~
```
[Desktop Entry]
Type=Application
Version=1.5
Name=go-hass-agent
Comment=A Home Assistant, native app for desktop/laptop devices.
Path=/usr/bin
Exec=go-hass-agent run
Icon=go-hass-agent
Terminal=false
Categories=System;Monitor;TrayIcon;
StartupNotify=true
Keywords=home;assistant;hass;
OnlyShowIn=GNOME;XFCE;KDE;
```

## Debian 12 using Chromium Without Desktop Environment 
This is a low overhead method without running a full desktop environment for what is ultimately a view of a single webpage.
* Based on work from: [HA-Chromium-Kiosk](https://github.com/kunaalm/HA-Chromium-Kiosk)
* I wasn't able to get go-hass-agent working the way I wanted it, so implemented a Bash script to publish/subscribe to MQTT message
to control the Kiosk monitor and be able to put CPU to sleep when nobody is home or at night:
   * DDCUtil (`sudo apt install ddcutil`) to control monitor (same as using the physical buttons on the monitor). Control Monitor sleep/wake state, brightness, color temperature, volume, etc.
   * Bash Script ran as a service:
       * Bash Script: [wallboard-listener.sh](https://github.com/smurf12345/home-assistant/blob/main/kiosk-wallboard/wallboard-listener.sh)
       * Service: [wallboard-listener.service](https://github.com/smurf12345/home-assistant/blob/main/kiosk-wallboard/wallboard-listener.service)
   * Home-Assistant Entity Configuration Yaml: [configuration.yaml](https://github.com/smurf12345/home-assistant/blob/main/kiosk-wallboard/configuration.yaml)

## Customizations
* Lovelace Card YAML Configurations can be found in Github code section ([Lovelace Cards](https://github.com/smurf12345/home-assistant))


