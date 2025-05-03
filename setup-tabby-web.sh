#!/bin/sh

# Check if jq is installed
if [ ! -x "$(which jq)" ]; then
    echo "\033[33mjq is not installed. Installing jq...\033[0m"
    apt-get -qq update && apt-get -qq install -y jq
fi

# Check if GITHUB_CLIENT_ID exists in .env file
ENV_FILE=".env"
if [ ! -f "$ENV_FILE" ] || ! grep -q "^GITHUB_CLIENT_ID=" "$ENV_FILE"; then
    echo "\033[32mGitHub client ID not found in .env file. Please enter your GitHub client ID:\033[0m"
    read GITHUB_CLIENT_ID
    if [ ! -f "$ENV_FILE" ]; then
        echo "GITHUB_CLIENT_ID=$GITHUB_CLIENT_ID" > "$ENV_FILE"
        echo ".env file created with GitHub client ID."
    else
        echo "GITHUB_CLIENT_ID=$GITHUB_CLIENT_ID" >> "$ENV_FILE"
        echo "GitHub client ID added to .env file."
    fi
else
    echo "GitHub client ID already exists in .env file."
fi

# Check if GITHUB_CLIENT_SECRET exists in .env file
if [ ! -f "$ENV_FILE" ] || ! grep -q "^GITHUB_CLIENT_SECRET=" "$ENV_FILE"; then
    echo "\033[32mGitHub client secret not found in .env file. Please enter your GitHub client secret:\033[0m"
    read GITHUB_CLIENT_SECRET
    if [ ! -f "$ENV_FILE" ]; then
        echo "GITHUB_CLIENT_SECRET=$GITHUB_CLIENT_SECRET" > "$ENV_FILE"
        echo ".env file created with GitHub client secret."
    else
        echo "GITHUB_CLIENT_SECRET=$GITHUB_CLIENT_SECRET" >> "$ENV_FILE"
        echo "GitHub client secret added to .env file."
    fi
else
    echo "GitHub client secret already exists in .env file."
fi

# Fetch the JSON file from the URL
URL="https://registry.npmjs.org/tabby-web-container/"
LATEST_VERSION=$(curl -s $URL | jq -r '."dist-tags".latest')
LATEST_VERSION_TIME=$(curl -s $URL | jq -r --arg version "$LATEST_VERSION" '.time[$version]')

# Print the latest version and its time
echo "Latest version of tabby-web: $LATEST_VERSION"
echo "Release time of latest version: $LATEST_VERSION_TIME"

# Bring up the Docker container
git clone https://github.com/gyf9835/tabby-web.git
cd tabby-web
git switch patch-2
rm /opt/tabby-web-setup/tabby-web/docker-compose.yml
ln -s /opt/tabby-web-setup/docker-compose.yml /opt/tabby-web-setup/tabby-web/docker-compose.yml
docker compose -f /opt/tabby-web-setup/tabby-web/docker-compose.yml up -d

# Check if the container is running
if [ "$(docker ps -q -f name=tabby)" ]; then
    echo "tabyy-web container is running."
    # docker compose run tabby /manage.sh add_version $LATEST_VERSION
else
    echo "Failed to start tabby-web."
    exit 1
fi
