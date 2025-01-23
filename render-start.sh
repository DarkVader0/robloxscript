export PATH="${PATH}:/opt/render/project/.render/chrome/opt/google/chrome"
export PATH="${PATH}:/opt/render/project/.render/chrome/usr/bin"

echo "Verifying Chrome binary path:"
ls -l /opt/render/project/.render/chrome/opt/google/chrome

echo "Verifying ChromeDriver path:"
ls -l /opt/render/project/.render/chrome/usr/bin/chromedriver

python main.py