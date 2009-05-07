#!/bin/sh


# load configure
if ! [ -f "./config.status" ] ; then
  echo "You must run configure before you can install."
  exit
fi

. ./config.status

# can we write to dirs?


