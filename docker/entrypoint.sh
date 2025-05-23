#!/usr/bin/env bash

cp /etc/resolv.conf /tmp/resolv.conf
umount /etc/resolv.conf
mv /tmp/resolv.conf /etc/resolv.conf
sed -i 's/DAEMON_ARGS=.*/DAEMON_ARGS=""/' /etc/init.d/expressvpn
service expressvpn restart

output=$(expect -f /expressvpn/activate.exp "$ACTIVATION_CODE")
if echo "$output" | grep -q "Please activate your account" > /dev/null || echo "$output" | grep -q "Activation failed" > /dev/null
then
    echo "Activation failed!"
    exit 1
fi

expressvpn preferences set auto_connect true
expressvpn preferences set preferred_protocol $PREFERRED_PROTOCOL
expressvpn preferences set lightway_cipher $LIGHTWAY_CIPHER

if [[ "$CONNECT_AT_STARTUP" == "true" ]]; then
  expressvpn connect $SERVER
fi

if [[ "$(expressvpn status)" == "Not Activated" ]]; then exit 1; fi

rm -r /vpn_shared/resolv.conf
cp /etc/resolv.conf /vpn_shared/

source .venv/bin/activate
cd /app
flask run --host=0.0.0.0
