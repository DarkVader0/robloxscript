#!/usr/bin/env bash
# exit on error
set -o errexit

# Install Python dependencies
pip install --upgrade pip
pip install -r requirements.txt

STORAGE_DIR=/opt/render/project/.render

if [[ ! -d $STORAGE_DIR/chrome ]]; then
  echo "...Downloading Chrome"
  mkdir -p $STORAGE_DIR/chrome
  cd $STORAGE_DIR/chrome
  wget -P ./ https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  dpkg -x ./google-chrome-stable_current_amd64.deb $STORAGE_DIR/chrome
  rm ./google-chrome-stable_current_amd64.deb
  cd $HOME/project/src # Make sure we return to where we were
else
  echo "...Using Chrome from cache"
fi

# Install ChromeDriver
if [[ ! -f $STORAGE_DIR/chrome/usr/bin/chromedriver ]]; then
  echo "...Downloading ChromeDriver"
  wget -P ./ https://chromedriver.storage.googleapis.com/114.0.5735.90/chromedriver_linux64.zip
  unzip chromedriver_linux64.zip -d $STORAGE_DIR/chrome/usr/bin
  chmod +x $STORAGE_DIR/chrome/usr/bin/chromedriver
  rm chromedriver_linux64.zip
else
  echo "...Using ChromeDriver from cache"
fi