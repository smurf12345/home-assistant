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

TOPIC="wallboard/#"                  # Subscribe to all subtopics under "wallboard/"
POWER_STATE_TOPIC="wallboard/monitor/power/state"
BRIGHTNESS_STATE_TOPIC="wallboard/monitor/brightness/state"
VOLUME_STATE_TOPIC="wallboard/monitor/volume/state"

# --- Functions ---
publish_power_state() {
    local state="$1"
    echo "[INFO] Publishing power state: $state"
    mosquitto_pub -h "$BROKER" -u "$USERNAME" -P "$PASSWORD" -t "$POWER_STATE_TOPIC" -m "$state"
}

check_power_state() {
    power_status=$(ddcutil getvcp D6 2>/dev/null | grep -oP '(?<=DPM: )[A-Za-z]+')

    # echo "[DEBUG] Raw power status: '$power_status'"  # Log the raw output for debugging

    if [[ "$power_status" == "On" ]]; then
        # Monitor is ON
        if [[ "$last_power_state" != "on" ]]; then
            # echo "[DEBUG] Monitor state changed to ON"
            last_power_state="on"
            publish_power_state "on"
        fi
    else
        # Monitor is OFF (fallback for empty or other values)
        if [[ "$last_power_state" != "off" ]]; then
            # echo "[DEBUG] Monitor state changed to OFF"
            last_power_state="off"
            publish_power_state "off"
        fi
    fi
}

handle_mqtt_command() {
    local topic="$1"
    local payload="$2"

    case "$topic" in
        "wallboard/monitor/power")
            case "$payload" in
                "on")
                    echo "[INFO] Command: Turning monitor on"
                    ddcutil setvcp D6 1
                    check_power_state
                    ;;
                "off")
                    echo "[INFO] Command: Turning monitor off"
                    ddcutil setvcp D6 5
                    check_power_state
                    ;;
                *)
                    echo "[WARN] Unknown power command: $payload"
                    ;;
            esac
            ;;
        "wallboard/monitor/brightness")
            if [[ "$payload" =~ ^[0-9]+$ && "$payload" -ge 0 && "$payload" -le 100 ]]; then
                echo "[INFO] Command: Setting brightness to $payload%"
                ddcutil setvcp 10 "$payload"
                mosquitto_pub -h "$BROKER" -u "$USERNAME" -P "$PASSWORD" -t "$BRIGHTNESS_STATE_TOPIC" -m "$payload"
            else
                echo "[WARN] Invalid brightness value: $payload (must be 0-100)"
            fi
            ;;
        "wallboard/monitor/volume")
            if [[ "$payload" =~ ^[0-9]+$ && "$payload" -ge 0 && "$payload" -le 100 ]]; then
                echo "[INFO] Command: Setting volume to $payload%"
                ddcutil setvcp 62 "$payload"
                mosquitto_pub -h "$BROKER" -u "$USERNAME" -P "$PASSWORD" -t "$VOLUME_STATE_TOPIC" -m "$payload"
            else
                echo "[WARN] Invalid volume value: $payload (must be 0-100)"
            fi
            ;;
        *)
            echo "[WARN] Unknown topic: $topic"
            ;;
    esac
}

# --- Publish Initial Brightness State ---
initial_brightness=$(ddcutil getvcp 10 | grep -Po 'current value =\s*\K\d+')
echo "[INFO] Initial brightness: $initial_brightness"
mosquitto_pub -h "$BROKER" -u "$USERNAME" -P "$PASSWORD" -t "$BRIGHTNESS_STATE_TOPIC" -m "$initial_brightness"

# Get initial volume
initial_volume=$(ddcutil getvcp 62 | grep -oP '(?<=Volume level: )[0-9]+')
echo "[INFO] Initial volume: $initial_volume"
mosquitto_pub -h "$BROKER" -u "$USERNAME" -P "$PASSWORD" -t "$VOLUME_STATE_TOPIC" -m "$initial_volume"

# --- Publish Initial Monitor Power State ---
echo "[INFO] Checking initial monitor power state..."
last_power_state=""
check_power_state

# --- Subscription Loop ---
mosquitto_sub -h "$BROKER" -p "$PORT" -u "$USERNAME" -P "$PASSWORD" -t "$TOPIC" -v |
while read -r full_message; do
    topic=$(echo "$full_message" | awk '{print $1}')
    payload=$(echo "$full_message" | cut -d ' ' -f2-)
    # echo "[DEBUG] MQTT message received:"
    # echo "  Topic: $topic"
    # echo "  Payload: $payload"

    handle_mqtt_command "$topic" "$payload"
done &

# --- Monitoring Loop ---
while true; do
    check_power_state
    sleep 5
done

