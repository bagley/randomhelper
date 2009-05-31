
# find needed perl modules

print "Checking PERL version... ";
eval "require 5.004";
if ($@) {
    print "This program requires at least PERL version 5.004 or greater\n";
    exit 1;
  }
print " OK\n";

print "Checking basic stuff... ";
eval "use strict";
if ( $@ ) {
	print "\nUnable to tell perl to use strict mode.\n";
	exit 1;
}

eval "use Fcntl qw(:DEFAULT :flock)";
if ( $@ ) {
	print "\nUnable to use file locking (Fcntl).\n";
	exit 1;
}
print " OK\n";

sub load_mods {
	my @mods = @_;
	for my $mod (@mods) {
		print "Checking for perl module $mod... ";
		eval "use $mod";
		if ( $@ ) {
			print "Failed\n";
			exit 1;
		}
		print " OK\n";
	}
}

load_mods( "Cwd",
           "Cwd qw(abs_path)",
           "Sys::Syslog",
           "File::Basename",
           "File::Copy",
           "File::Temp qw( tempdir )",
           "Time::HiRes qw( usleep )",
           "Date::Format"
           );

print "Checking for sys/ioctl.ph, required to add entropy to the kernel... ";
eval "require 'sys/ioctl.ph'";
if ( $@ ) {
	print "Failed\n";
	print "Perhaps you need to install your kernel headers, it is located elsewhere, or has not been generated.\n";
	exit 1;
}
print " OK\n";
#eval "require '_h2ph_pre.ph'";
#if ( $@ ) {
#	print "\nFailed to load module Cwd (abs_path).\n";
#	exit 1;
#}

# all good
exit 0;
