#!/bin/sh

# Path to the Docker secret (adjust the path as needed)
MOSQUITTO_PASSWORD_FILE="/run/secrets/mosquitto-password"

# Check if the Docker secret for Mosquitto password exists
if [ -f "${MOSQUITTO_PASSWORD_FILE}" ]; then
    MOSQUITTO_PASSWORD=$(cat "${MOSQUITTO_PASSWORD_FILE}")
elif [ -n "${MOSQUITTO_PASSWORD}" ]; then
    # If the secret isn't there, fall back to the environment variable
    MOSQUITTO_PASSWORD=${MOSQUITTO_PASSWORD}
else
    echo "Mosquitto password not set. Exiting."
    exit 1
fi

# Create Mosquitto username and password if they're provided
if [ -n "${MOSQUITTO_USERNAME}" ] && [ -n "${MOSQUITTO_PASSWORD}" ]; then
    mosquitto_passwd -b -c /mosquitto/config/pass "${MOSQUITTO_USERNAME}" "${MOSQUITTO_PASSWORD}"
    chown mosquitto:mosquitto /mosquitto/config/pass
fi

# Execute the main CMD from the Dockerfile
exec "$@"
