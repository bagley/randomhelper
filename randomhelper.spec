%define name randomhelper
%define version 0.3.2
%define release 1

%define username randomhelper
%define groupname %{username}
# dont change - installer ignores this
%define homedir /var/lib/randomhelper

Summary: Background program to keep random number generator from starving
Name: %{name}
Version: %{version}
Release: %{release}
#Source: ftp://ftp.worldforge.org/pub/worldforge/libs/%{name}-%{version}.tar.gz
Source: %{name}-%{version}.tar.gz
Vendor: Matt Bagley
URL: none
License: GPL
Group: System Environment/Utilities
Buildroot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
#Prefix: %{_prefix}
Requires: perl perl-TimeDate gcc rng-utils compat-libstdc++-33 shadow-utils
BuildRequires: perl perl-TimeDate gcc rng-utils compat-libstdc++-33

%description
This program will keep your random number generator filled with secure
random data, from a source you specify. It helps prevent the the rng 
from starving, and can be used either as a replacement or compliment 
to a hardware based rng.

%pre
getent group %{groupname} >/dev/null || groupadd -r %{groupname}
getent passwd %{username} >/dev/null || \
useradd -r -M -g %{groupname} --home %{homedir} -s /bin/bash \
-c "User for running scripts to collect random data" %{username}

%prep
%setup -q
getent group %{groupname} >/dev/null || groupadd -r %{groupname}
getent passwd %{username} >/dev/null || \
useradd -r -M -g %{groupname} --home %{homedir} -s /bin/bash \
-c "User for running scripts to collect random data" %{username}

%build
./configure --prefix=/usr --user=%{username} --nousercreate

%install
rm -rf $RPM_BUILD_ROOT
DESTDIR=$RPM_BUILD_ROOT ./install.sh

%clean
rm -rf $RPM_BUILD_ROOT
./install.sh clean

%post
/sbin/chkconfig --add randomhelper
#for n in /var/log/{messages,secure,maillog,spooler}
#do
#        [ -f $n ] && continue
#        umask 066 && touch $n
#done

%preun
if [ "$1" -eq "0" ]; then
        service randomhelper stop >/dev/null 2>&1 ||:
        /sbin/chkconfig --del randomhelper
fi

%postun
if [ "$1" -ge "1" ]; then
        /etc/init.d/randomhelper condrestart > /dev/null 2>&1 ||:
fi

%files
%attr(0750, randomhelper, randomhelper) /usr/sbin/random-collector
%attr(0700, root, root) /usr/sbin/random-add
%attr(0755, root, root) /etc/init.d/randomhelper
%attr(0700, randomhelper, randomhelper) %dir /usr/share/randomhelper/*/*/*
%attr(0700, randomhelper, randomhelper) %dir /var/lib/randomhelper
%verify(not md5 size mtime) %attr(0750, randomhelper, randomhelper) %config(noreplace) /etc/randomhelper
%doc COPYING README TODO

%changelog
* Thu Mar 7 2002 T.R. Fullhart <kayos@kayos.org>
- First draft of the spec file
