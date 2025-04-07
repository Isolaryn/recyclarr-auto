#!/usr/bin/env bash
# Clone or pull the config-templates repo
if [ -d /config/templates ]; then
    echo "Updating config-templates"
    git -C /config/templates pull
else
    echo "Cloning config-templates"
    git clone https://github.com/recyclarr/config-templates /config/templates
fi

# templates are in /config/templates/{sonarr,radarr}/templates
# TEMPLATE_TYPE: sonarr | radarr
# TEMPLATE_NAME: name of the template (excluding .yml)
# TEMPLATE_BASE_URL: base url of the sonarr/radarr instance
# TEMPLATE_API_KEY: api key of the sonarr/radarr instance
# TEMPLATE_INSTANCE_NAME: name of the instance in the template

# Ensure env vars are set
if [ -z "$TEMPLATE_TYPE" ]; then
    echo "TEMPLATE_TYPE is required, valid values are sonarr or radarr"
    exit 1
fi

if [ -z "$TEMPLATE_NAME" ]; then
    echo "TEMPLATE_NAME is not set, this is the name of the template file (excluding .yaml)"
    exit 1
fi

if [ -z "$TEMPLATE_BASE_URL" ]; then
    echo "TEMPLATE_BASE_URL is not set"
    exit 1
fi

if [ -z "$TEMPLATE_API_KEY" ]; then
    echo "TEMPLATE_API_KEY is not set"
    exit 1
fi

if [ -z "$TEMPLATE_INSTANCE_NAME" ]; then
    echo "TEMPLATE_INSTANCE_NAME is not set"
    exit 1
fi

# Ensure template exists
echo "Looking for template $TEMPLATE_NAME.yml in /config/templates/$TEMPLATE_TYPE/templates"
TEMPLATE_FILE=$(find /config/templates/$TEMPLATE_TYPE/templates -name "$TEMPLATE_NAME.yml")
if [ -z "$TEMPLATE_FILE" ]; then
    echo "Template $TEMPLATE_NAME.yaml not found in /config/templates/$TEMPLATE_TYPE"
    exit 1
fi
if [ $(echo "$TEMPLATE_FILE" | wc -l) -gt 1 ]; then
    echo "Multiple templates found for $TEMPLATE_NAME, please ensure only one exists"
    exit 1
fi
echo "Using template $TEMPLATE_FILE"

# Copy selected template to /config/recyclarr.yml overriding it
cp $TEMPLATE_FILE /config/recyclarr.yml

# using yq set the required keys
# sonarr:
#   anime-sonarr-v4:
#     base_url: Put your Sonarr URL here
#     api_key: Put your API key here
yq -e -i ".$TEMPLATE_TYPE.$TEMPLATE_INSTANCE_NAME.base_url = \"$TEMPLATE_BASE_URL\"" /config/recyclarr.yml
yq -e -i ".$TEMPLATE_TYPE.$TEMPLATE_INSTANCE_NAME.api_key = \"$TEMPLATE_API_KEY\"" /config/recyclarr.yml

# Start the app
/entrypoint.sh "$@"