#!/bin/bash

cd /home/randomhelper/apps/

clean_up() {
	killall qrand
	exit 1
}
trap "clean_up" SIGINT SIGHUP SIGTERM

./qrand /N:$1

exit $?
