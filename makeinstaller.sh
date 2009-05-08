#!/bin/bash

dir=randomhelper-0.2

rm -drf "./$dir"
rm -f "${dir}.tar.gz"

mkdir "$dir"

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
