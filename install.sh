#!/bin/sh

PATH="/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:$PREFIX/bin:$PREFIX/sbin"

DIR=$(pwd)

chk_config() {
  # load configure
  if ! [ -f "./config.status" ] || ! [ -f "./config.vars" ] ; then
    echo "You must run configure before you can install/uninstall."
    exit
  fi
}
error() {
	echo "Error: $*"
	exit
}
get_vars() {
	. ./config.vars
	INSTALLDIR="install -d -D "
	INSTALLUSER="install -D -o $RANDUSER -g root -m 550"
	INSTALLROOT="install -D -o root -g root -m 755"
}
get_priority() {
  	echo "size=200" > "${DESTDIR}/etc/randomhelper"
	chmod 640 "${DESTDIR}/etc/randomhelper"
	chown "root:$RANDUSER" "${DESTDIR}/etc/randomhelper"
	cd "$DIR/plugins"
	for EACH in `ls -1 "${DESTDIR}$PREFIX/share/randomhelper/plugins"` ; do
	  # set priorities
	  priority=5
	  priority_test=$("${DESTDIR}$PREFIX/share/randomhelper/plugins/$EACH/run" --priority)
	  if [ -n "$priority_test" -a $priority_test -ge 1 -a $priority_test -le 10 ] ; then
	    priority=$priority_test
	  fi
	  echo "$EACH priority set to $priority"
	  [ -z "$(echo $plugins | grep $EACH)" ] && commented="#" || commented=""
	  echo "$commented$EACH=$priority" >> "${DESTDIR}/etc/randomhelper"
	done
}
add_munin() {
  #if [ -d "${DESTDIR}/etc/munin/plugins" ] ; then
    install -d -m 755 ./munin/entropyusage ${DESTDIR}/etc/munin/plugins/entropyusage
  #fi
}

case $1 in
	clean)
		set -x
		rm -f config.status config.vars
		;;
	
	uninstall)
		chk_config
		set -x
		get_vars
		"$INIT/randomhelper" stop
		chkconfig --del randomhelper                   			|| echo "Failed"
		rm -f "$DESTDIR$INIT/randomhelper"              		|| echo "Failed"
		#rm -f "/etc/randomhelper"                   			|| echo "Failed"
		rm -f "$DESTDIR$PREFIX/sbin/random-collector"                   || echo "Failed"
		rm -f "$DESTDIR$PREFIX/sbin/random-add"                   	|| echo "Failed"
		rm -drf "$DESTDIR$PREFIX/share/randomhelper"                   	|| echo "Failed"
		rm -f $DESTDIR/var/lib/randomhelper/tmp/*
		rmdir $DESTDIR/var/lib/randomhelper/tmp
		rm -f $DESTDIR/var/lib/randomhelper/*                   	|| echo "Failed"
		rmdir $DESTDIR/var/lib/randomhelper                   		|| echo "Failed"
		set +x
		echo "You may want to remove the configured user $RANDUSER."
  		echo "Usually you can run: deluser --group $RANDUSER"
 		echo "Of course, this assumes you made a user ONLY for this program."
  		echo "Do NOT use it if you were using your account to run the program!" 
  		exit
  		;;
		
	help|--help|-h)  echo "Usage: <install uninstall clean>" ;;
	
	*)
		chk_config
		set -x
		get_vars
		. ./config.status
		$INSTALLROOT $DIR/random-add ${DESTDIR}${PREFIX}/sbin/random-add               || error "Failed"
		$INSTALLUSER $DIR/random-collector.sed ${DESTDIR}${PREFIX}/sbin/random-collector   || error "Failed"
		$INSTALLDIR -m 700 -o $RANDUSER -g $RANDUSER ${DESTDIR}/var/lib/randomhelper                 		|| error "Failed"
		$INSTALLROOT $DIR/initd/randomhelper.sed "${DESTDIR}/${INIT}/randomhelper"     || error "Failed"
		[ -z "${DESTDIR}" ] && chkconfig --add randomhelper
		$INSTALLDIR "${DESTDIR}$PREFIX/share/randomhelper/plugins/"		|| error "Failed"
		cp -r $DIR/plugins/* "${DESTDIR}${PREFIX}/share/randomhelper/plugins/"	|| error "Failed"
		chown "$RANDUSER:$RANDUSER" -R "${DESTDIR}${PREFIX}/share/randomhelper/plugins"	|| error "Failed"
		chmod u=rwX,g=rX,o-rwx -R "${DESTDIR}${PREFIX}/share/randomhelper"	|| error "Failed"
		get_priority
		set +x
		echo "You can now configure the program by running:"
		echo "su - \"$RANDUSER\" -c \"${DESTDIR}${PREFIX}/sbin/random-collector --config"
		echo "Then you can start the program with ${INIT}/randomhelper start"
		;;	
	
esac
