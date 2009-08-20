%define name randomhelper
%define version VERSION
%define release RELEASE

%define username randomhelper
%define groupname randomhelper
%define homedir /var/lib/randomhelper

Summary: Background program to keep random number generator from starving
Name: %{name}
Version: %{version}
Release: %{release}
#Source: ftp://ftp.worldforge.org/pub/worldforge/libs/%{name}-%{version}%{release}.tar.gz
Source0: %{name}-%{version}%{release}.tar.gz
Vendor: Matt Bagley
URL: none
License: GPL
Group: System Environment/Utilities
Prefix: %{_prefix}
Requires(pre): shadow-utils
Requires: perl perl-datetime gcc rng-tools

%description
This program will keep your random number generator filled with secure
random data, from a source you specify. It helps prevent the the rng 
from starving, and can be used either as a replacement or compliment 
to a hardware based rng.

%pre
getent group %{groupname} >/dev/null || groupadd -r %{groupname}
getent passwd %{username} >/dev/null || \
useradd -r -M -g %{groupname} -d %{homedir} -s /bin/bash \
-c "User for running scripts to collect random data" %{username}

%prep
%setup -q

%build
# interface address
./configure --prefix=/usr

%install
rm -rf $RPM_BUILD_ROOT
./install.sh 
#--prefix=$RPM_BUILD_ROOT/usr
#install -m 755 /usr/sbin/random-collector
#install -m 755 /usr/sbin/random-add
#/usr/share/randomhelper/plugins/
#mkdir -p /var/lib/randomhelper
#install -m 600 config/randomhelper ${RPM_BUILD_ROOT}%{_sysconfdir}/randomhelper

%clean
rm -rf $RPM_BUILD_ROOT

%post server
chkconfig --add randomhelper
service randomhelper condrestart

%postun server
service randomhelper stop
chkconfig --del randomhelper

%files
%attr(0750, randomhelper, randomhelper) %{_sbindir}/random-collector
%attr(0700, root, root) %{_sbindir}/random-add
%attr(0755, root, root) %{_sysconfdir}/init.d/randomhelper
%verify(not md5 size mtime) %ghost %config(missingok,noreplace) %{_sysconfdir}/randomhelper
%attr(0700, randomhelper, randomhelper) %dir 
/var/lib/randomhelper
/usr/bin/share/randomhelper
/usr/bin/share/randomhelper/plugins/*


%changelog
* Thu Mar 7 2002 T.R. Fullhart <kayos@kayos.org>
- First draft of the spec file
