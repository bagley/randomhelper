#!/bin/bash

set -x

dir=randomhelper-0.3

rm -drf "./$dir"
rm -f "${dir}.tar.gz"

mkdir "$dir"

set +x
chmod +x configure install.sh config.perl plugins/entropyusage
chmod -x random-collector random-get
for EACH in `ls plugins` ; do
  [ -d "plugins/$EACH" ] && chmod +x "plugins/$EACH/run"
done

for EACH in random-collector random-get ; do
  perl -c $EACH
  if [ $? -ne 0 ] ; then
    echo "Failed $EACH"
    exit
  fi
done
set -x

cp -a "initd" "$dir/"
cp -a "plugins" "$dir/"
rm -f "$dir/plugins/qrand/qrand"

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

tar czf "${dir}.tar.gz" "$dir"

rm -drf "./$dir"
