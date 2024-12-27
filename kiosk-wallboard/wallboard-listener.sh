#!/usr/bin/env bash
#
# Script: wallboard_listener.sh
# Purpose: Subscribe to all "wallboard/#" topics and handle specific subtopics and payloads.

# --- Configuration ---
BROKER="<Replace with IP/URL>"       # MQTT broker address
TOPIC="wallboard/#"                  # Subscribe to all subtopics under "wallboard/"
USERNAME="<Replace with Username>"   # MQTT username
PASSWORD="<Replace with Password>"   # MQTT password
PORT=1883                            # Default MQTT port is 1883

# --- Publish Initial Brightness State ---
initial_brightness=$(ddcutil getvcp 10 | grep -oP '(?<=current value: )[0-9]+')
echo "[INFO] Initial brightness: $initial_brightness"
mosquitto_pub -h "$BROKER" -u "$USERNAME" -P "$PASSWORD" -t "wallboard/monitor/brightness/state" -m "$initial_brightness"

# Get initial volume
initial_volume=$(ddcutil getvcp 62 | grep -oP '(?<=Volume level: )[0-9]+')
echo "[INFO] Initial volume: $initial_volume"
mosquitto_pub -h "$BROKER" -u "$USERNAME" -P "$PASSWORD" -t "wallboard/monitor/volume/state" -m "$initial_volume"

# --- Subscription Loop ---
mosquitto_sub -h "$BROKER" -p "$PORT" -u "$USERNAME" -P "$PASSWORD" -t "$TOPIC" -v \
  | while read -r full_message
do
    # Split the message into topic and payload
    topic=$(echo "$full_message" | awk '{print $1}')
    payload=$(echo "$full_message" | cut -d ' ' -f2-)

    echo "[DEBUG] Raw MQTT message received:"
    echo "  Topic: $topic"
    echo "  Payload: $payload"

    # Parse topic and payload
    case "$topic" in
      "wallboard/monitor/power")
        case "$payload" in
          "on")
            echo "[INFO] Command: Turning monitor on (DPMS)"
            ddcutil setvcp d6 1
            ;;
          "off")
            echo "[INFO] Command: Turning monitor off (DPMS)"
            ddcutil setvcp d6 5
            ;;
          *)
            echo "[WARN] Unknown power payload: $payload"
            ;;
        esac
        ;;

      "wallboard/monitor/brightness")
        if [[ "$payload" =~ ^[0-9]+$ && "$payload" -ge 0 && "$payload" -le 100 ]]; then
          echo "[INFO] Command: Setting brightness to $payload%"
          ddcutil setvcp 10 "$payload"
          mosquitto_pub -h "$BROKER" -u "$USERNAME" -P "$PASSWORD" -t "wallboard/monitor/brightness/state" -m "$payload"
        else
          echo "[WARN] Invalid brightness value: $payload (must be 0-100)"
        fi
        ;;

      # Volume Handling
      "wallboard/monitor/volume")
        if [[ "$payload" =~ ^[0-9]+$ && "$payload" -ge 0 && "$payload" -le 100 ]]; then
          echo "[INFO] Command: Setting volume to $payload%"
          ddcutil setvcp 62 "$payload"
          mosquitto_pub -h "$BROKER" -u "$USERNAME" -P "$PASSWORD" -t "wallboard/monitor/volume/state" -m "$payload"
        else
          echo "[WARN] Invalid volume value: $payload (must be 0-100)"
        fi
        ;;

      "wallboard/monitor/color_preset")
        case "$payload" in
          "5000 K")
            echo "[INFO] Command: Setting color preset to 5000 K"
            ddcutil setvcp 14 04
            ;;
          "6500 K")
            echo "[INFO] Command: Setting color preset to 6500 K"
            ddcutil setvcp 14 05
            ;;
          "7500 K")
            echo "[INFO] Command: Setting color preset to 7500 K"
            ddcutil setvcp 14 06
            ;;
          "9300 K")
            echo "[INFO] Command: Setting color preset to 9300 K"
            ddcutil setvcp 14 08
            ;;
          "User 1")
            echo "[INFO] Command: Setting color preset to User 1"
            ddcutil setvcp 14 0b
            ;;
          *)
            echo "[WARN] Unknown color preset: $payload"
            ;;
        esac
        ;;

      "wallboard/cpu/command")
        case "$payload" in
          "suspend")
            echo "[INFO] Command: Suspending the system"
            sudo systemctl suspend
            ;;
          "reboot")
            echo "[INFO] Command: Rebooting the system"
            sudo systemctl reboot
            ;;
          *)
            echo "[WARN] Unknown CPU command: $payload"
            ;;
        esac
        ;;

      *)
        echo "[WARN] Unknown topic: $topic"
        ;;
    esac
done
