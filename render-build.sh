#!/usr/bin/env bash
# exit on error
set -o errexit

# Install Python dependencies
pip install --upgrade pip
pip install -r requirements.txt

STORAGE_DIR=/opt/render/project/.render

# Install Chrome if not cached
if [[ ! -d $STORAGE_DIR/chrome ]]; then
  echo "...Downloading Chrome"
  mkdir -p $STORAGE_DIR/chrome
  cd $STORAGE_DIR/chrome
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  dpkg -x ./google-chrome-stable_current_amd64.deb .
  rm ./google-chrome-stable_current_amd64.deb
else
  echo "...Using Chrome from cache"
fi

# Install ChromeDriver (use a compatible version for the installed Chrome)
if [[ ! -f $STORAGE_DIR/chrome/usr/bin/chromedriver ]]; then
  echo "...Downloading ChromeDriver"
  wget -P ./ https://chromedriver.storage.googleapis.com/114.0.5735.90/chromedriver_linux64.zip
  unzip chromedriver_linux64.zip -d $STORAGE_DIR/chrome/usr/bin
  chmod +x $STORAGE_DIR/chrome/usr/bin/chromedriver
  rm chromedriver_linux64.zip
else
  echo "...Using ChromeDriver from cache"
fi

# Set the Chrome and ChromeDriver binary locations for Selenium
export PATH="${PATH}:/opt/render/project/.render/chrome/opt/google/chrome"
export PATH="${PATH}:/opt/render/project/.render/chrome/usr/bin"