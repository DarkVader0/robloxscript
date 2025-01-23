#!/usr/bin/env bash
# exit on error
set -o errexit

# Install Python dependencies
pip install --upgrade pip
pip install -r requirements.txt

STORAGE_DIR=/opt/render/project/.render

# Install Chrome version 114
if [[ ! -d $STORAGE_DIR/chrome ]]; then
  echo "...Downloading Chrome version 114"
  mkdir -p $STORAGE_DIR/chrome
  cd $STORAGE_DIR/chrome
  wget https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_114.0.5735.90-1_amd64.deb
  dpkg -x ./google-chrome-stable_114.0.5735.90-1_amd64.deb $STORAGE_DIR/chrome
  rm ./google-chrome-stable_114.0.5735.90-1_amd64.deb
  cd $HOME/project/src
else
  echo "...Using Chrome version 114 from cache"
fi

# Install ChromeDriver version 114
if [[ ! -f $STORAGE_DIR/chrome/usr/bin/chromedriver ]]; then
  echo "...Downloading ChromeDriver version 114"
  wget -P ./ https://chromedriver.storage.googleapis.com/114.0.5735.90/chromedriver_linux64.zip
  unzip chromedriver_linux64.zip -d $STORAGE_DIR/chrome/usr/bin
  chmod +x $STORAGE_DIR/chrome/usr/bin/chromedriver
  rm chromedriver_linux64.zip
else
  echo "...Using ChromeDriver version 114 from cache"
fi