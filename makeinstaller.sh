#!/bin/bash

app=randomhelper
version=0.3
release=-1

dir="$app-$version$release"

makeinstall() {

personal="$1"

set -x

rm -drf "./$dir"
rm -f "${dir}${personal}.tar.gz"

mkdir "$dir"

set +x
chmod +x configure install.sh config.perl plugins/entropyusage
chmod -x random-collector random-get
for EACH in `ls plugins` ; do
  [ -d "plugins/$EACH" ] && chmod +x "plugins/$EACH/run"
done

for EACH in configure install.sh initd/randomhelper; do
  sh -n $EACH
  if [ $? -ne 0 ] ; then
    echo "Failed $EACH"
    exit
  fi
done

for EACH in random-collector random-get plugins/entropyusage; do
  perl -c $EACH
  if [ $? -ne 0 ] ; then
    echo "Failed $EACH"
    exit
  fi
done
set -x

cp -a "initd" "$dir/"
cp -a "plugins" "$dir/"
if [ "$personal" == ".personal" ] ; then
  mv -f "$dir/plugins/qrand/qrbg-personal.ini" "$dir/plugins/qrand/qrbg.ini"
else
  rm -f "$dir/plugins/qrand/qrand" "$dir/plugins/qrand/qrbg-personal.ini"
fi

cp -a "config.perl" "$dir/"
cp -a "configure" "$dir/"

cp -a "install.sh" "$dir/"

cp -a "random-collector" "$dir/"
cp -a "random-get" "$dir/random-add"

fold -sw 70 "COPYING" > "$dir/COPYING"
fold -sw 70 "INSTALL" > "$dir/INSTALL"
fold -sw 70 "README" > "$dir/README"

mkdir "$dir/munin"
mv "$dir/plugins/entropyusage" "$dir/munin/entropyusage"

cp -a randomhelper.spec "$dir/randomhelper${personal}.spec"
sed -i'' "s/VERSION/$version/g" "$dir/randomhelper${personal}.spec"
sed -i'' "s/RELEASE/$release/g" "$dir/randomhelper${personal}.spec"

tar czf "${dir}${personal}.tar.gz" "$dir"

rm -drf "./$dir"

set +x

}

makeinstall
makeinstall .personal
 
# build rpm
