#!/bin/sh

installdir=$(pwd)

# load configure
if ! [ -f "./config.status" ] ; then
  echo "You must run configure before you can install/uninstall."
  exit
fi

. ./config.status

PATH="/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:$PREFIX/bin:$PREFIX/sbin"

error() {
	echo "Error: $*"
	exit
}

# root?
#[ $UID -eq 0 ] || error "Must be root to install."

# what's happening
if [ -n "$1" ] ; then
  if [ "$1" != "uninstall" ] ; then
    error "Only arg is 'uninstall', otherwise we install."
  fi
  # uninstall files
  set -x
  if [ -x "$INIT/randomhelper" ] ; then
    "$INIT/randomhelper" stop
    rm -f "$INIT/randomhelper"
  fi
  rm -f "/etc/randomhelper"
  rm -f "$PREFIX/sbin/random-collector"
  rm -f "$PREFIX/sbin/random-add"
  rm -drf "$PREFIX/share/randomhelper"
  set +x
  
  # remove database
  echo "Would you like to remove the database of random data?"
  read -p "This file usually takes up over 300 MB of space. (y/n)" RESP
  if [ "$RESP" = "y" ] ; then
    set -x
    rm -f /var/lib/randomhelper/*
    rmdir /var/lib/randomhelper
    set +x
  fi
  echo "You may want to remove the configured user $RANDUSER."
  echo "Usually you can run: deluser --group $RANDUSER"
  echo "Of course, this assumes you made a user ONLY for this program."
  echo "Do NOT use it if you were using your account to run the program!"
  exit
fi


# install

# add user if needed
if [ "$MAKEUSER" = "y" ] ; then
  echo "Adding user $RANDUSER"
  SHELL=""
  [ -x /bin/sh ] && SHELL="--shell /bin/sh"
  [ -x /bin/bash ] && SHELL="--shell /bin/bash"
  # we want to make our own passwords - or maybe not
  # head -c 200 /dev/urandom | tr -cd '[:graph:]' | head -c 20 > ./install.pwd
  set -x
  adduser --system --group --home "/var/lib/randomhelper" $SHELL \
    --no-create-home --disabled-password "$RANDUSER"
  set +x
else
  echo "Skipping adding user"
fi

# make dirs
for EACH in "$PREFIX/bin" "$PREFIX/sbin" "$PREFIX/share/randomhelper" ; do
  set -x
  mkdir -p --mode=755 "$EACH" || error "Could not make directory $EACH"
  set +x
done
set -x
mkdir -p "/var/lib/randomhelper"
chmod 0700 "/var/lib/randomhelper"
chown "$RANDUSER:$RANDUSER" "/var/lib/randomhelper"
set +x

# do actual install
echo "Performing install"
set -x
cd "$installdir"

install -o "$RANDUSER" -g "$RANDUSER" -m 0700 random-collector \
  "$PREFIX/sbin/random-collector"
sed -i '' -e"s/{PREFIX}/$PREFIX/g" "$PREFIX/sbin/random-add"

install -m 0700 random-get "$PREFIX/sbin/random-add"
sed -i '' -e"s/my \$RNDADDENTROPY=0x40085203;/my \$RNDADDENTROPY=$RNGADDRESS;/"\
   "$PREFIX/sbin/random-add"

cd "$installdir/initd"
install -m 755 randomhelper "$INIT/randomhelper"
sed -i '' -e"s/\$PREFIX/$PREFIX/g" "$INIT/randomhelper"
sed -i '' -e"s/\$RANDUSER/$RANDUSER/g" "$INIT/randomhelper"
set +x

# set priorities
echo "size=300" > "/etc/randomhelper"

# plugins
cd "$installdir/plugins"
for EACH in $plugins ; do
  set -x
  install -d -o "$RANDUSER" -g "$RANDUSER" -m 0700 $EACH \
    "$PREFIX/share/randomhelper/plugins/$EACH"
  set +x
  priority=50
  [ -f "$EACH/priority" ] && priority=$(cat "$EACH/priority")
  echo "$EACH=$priority" >> "/etc/randomhelper"
done

set +x
exit
