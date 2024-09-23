#!/bin/bash

# Set environment variables
ADMIN_USERNAME=${KEYCLOAK_ADMIN_USERNAME}
ADMIN_PASSWORD=${KEYCLOAK_ADMIN_PASSWORD}
SERVER_DOMAIN=${SERVER_DOMAIN}
REALM="master"
CLIENT_ID="account"
REDIRECT_URI="https://${SERVER_DOMAIN}/callback"

# Login to Keycloak
/opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080/ --realm ${REALM} --user ${ADMIN_USERNAME} --password ${ADMIN_PASSWORD}

# Get client UUID for account client
CLIENT_UUID=$(/opt/keycloak/bin/kcadm.sh get clients -r ${REALM} -q clientId=${CLIENT_ID} | jq -r '.[0].id')

# Add redirect URI
if [ -n "${CLIENT_UUID}" ]; then
  sudo /opt/keycloak/bin/kcadm.sh update clients/${CLIENT_UUID} -r ${REALM} -s 'redirectUris=["'${REDIRECT_URI}'"]'
else
  echo "Client UUID not found for clientId=${CLIENT_ID}"
  exit 1
fi

# Enable user registration
sudo /opt/keycloak/bin/kcadm.sh update realms/${REALM} -s 'registrationAllowed=true'
