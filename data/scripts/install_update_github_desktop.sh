#!/bin/bash

echo "Searching for the latest GitHub Desktop version..."

GH_REPO_URL="https://github.com/shiftkey/desktop"
GH_VERSION=$(git ls-remote --tags "$GH_REPO_URL" | awk -F'/' '{print $3}' | grep -oP '\d+\.\d+\.\d+\-linux\d+' | tail -n 1)

if [ -z "$GH_VERSION" ]; then
  echo "Error: Could not find the latest tag."
  exit 1
fi

ARTIFACT_NAME="GitHubDesktop-linux-amd64-$GH_VERSION.deb"
RELEASE_URL="https://github.com/shiftkey/desktop/releases/download/release-$GH_VERSION/$ARTIFACT_NAME"

cd /tmp

echo "Downloading $ARTIFACT_NAME... (This may take a while)"
wget -q "$RELEASE_URL" -O "$ARTIFACT_NAME"

if [ $? -ne 0 ]; then
  echo "Error: Failed to download the release."
  exit 1
fi

echo "Download complete! Requesting permission to install..."
pkexec env DEBIAN_FRONTEND=noninteractive apt-get install -y -q -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" "/tmp/$ARTIFACT_NAME"

if [ $? -eq 0 ]; then
  echo "GitHub Desktop installed successfully!"
else
  echo "Error: Installation failed or was canceled."
  exit 1
fi

rm -f "/tmp/$ARTIFACT_NAME"