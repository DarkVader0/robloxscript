#!/usr/bin/env bash
# exit on error
set -o errexit

# Install Python dependencies
pip install --upgrade pip
pip install -r requirements.txt

apt-get update
apt-get install -y \
    libnss3 \
    libgconf-2-4 \
    libxss1 \
    libappindicator1 \
    libindicator7 \
    fonts-liberation \
    xvfb \
    libxtst6 \
    libgbm-dev \
    libasound2 \
    dbus \
    dbus-x11

STORAGE_DIR=/opt/render/project/.render

# Check if Chrome and ChromeDriver exist
if [[ -d $STORAGE_DIR/chrome ]]; then
  echo "...Removing existing Chrome and ChromeDriver"
  rm -rf $STORAGE_DIR/chrome
fi

# Install Chrome version 114
echo "...Downloading Chrome version 114"
mkdir -p $STORAGE_DIR/chrome
cd $STORAGE_DIR/chrome
wget https://mirror.cs.uchicago.edu/google-chrome/pool/main/g/google-chrome-stable/google-chrome-stable_114.0.5735.90-1_amd64.deb
dpkg -x ./google-chrome-stable_114.0.5735.90-1_amd64.deb $STORAGE_DIR/chrome
rm ./google-chrome-stable_114.0.5735.90-1_amd64.deb

# Install ChromeDriver version 114
echo "...Downloading ChromeDriver version 114"
wget -P ./ https://chromedriver.storage.googleapis.com/114.0.5735.90/chromedriver_linux64.zip
unzip -o chromedriver_linux64.zip -d $STORAGE_DIR/chrome/usr/bin  # Overwrite without prompting
chmod +x $STORAGE_DIR/chrome/usr/bin/chromedriver
rm chromedriver_linux64.zip