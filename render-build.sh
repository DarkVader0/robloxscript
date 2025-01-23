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
  dpkg -x ./google-chrome-stable_current_amd64.deb $STORAGE_DIR/chrome
  rm ./google-chrome-stable_current_amd64.deb
  cd $HOME/project/src
else
  echo "...Using Chrome from cache"
fi

# Get the current Chrome version
CHROME_VERSION=$($STORAGE_DIR/chrome/opt/google/chrome/google-chrome --version | awk '{print $3}' | cut -d. -f1)

# Install ChromeDriver for the detected Chrome version
if [[ ! -f $STORAGE_DIR/chrome/usr/bin/chromedriver || $CHROME_VERSION != $(basename $STORAGE_DIR/chrome/usr/bin/chromedriver) ]]; then
  echo "...Downloading ChromeDriver for Chrome $CHROME_VERSION"
  wget -P ./ https://chromedriver.storage.googleapis.com/${CHROME_VERSION}.0.0/chromedriver_linux64.zip
  unzip chromedriver_linux64.zip -d $STORAGE_DIR/chrome/usr/bin
  chmod +x $STORAGE_DIR/chrome/usr/bin/chromedriver
  rm chromedriver_linux64.zip
else
  echo "...Using ChromeDriver from cache"
fi