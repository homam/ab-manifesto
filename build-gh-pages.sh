rm -rf temp
mkdir temp
mkdir -p temp/home/style
mkdir -p temp/home/javascript
lsc build-gh-pages.ls > temp/index.html
./build.sh
cp views/home/javascript/*.js temp/home/javascript/
cp views/home/style/*.css temp/home/style/
git checkout gh-pages
mv temp/* . 
