#! /usr/bin/perl -w
use strict;

use File::Spec::Functions;
use FindBin;
use lib $FindBin::Bin;
use File::Copy;
use JSON;
use Path::Tiny;
use POSIX ();

=pod

perl ./tssmokeperl.pl -c "$CFGNAME" $continue $*

=cut

my @argv = @ARGV;

my $smokeperl_program = File::Spec->catfile($FindBin::Bin, 'tslogsmokeperl.pl');
my $lfile = File::Spec->catfile($FindBin::Bin, 'smokecurrent.log'); # TODO: make configurable
die "Could not locate $smokeperl_program" unless -f $smokeperl_program;

system(qq|$^X $smokeperl_program @argv > $lfile 2>&1|)
    and die "$smokeperl_program exited non-zero status: $!";

# TODO: The 'perl-current' directory must be determined from
# smokecurrent_config, as it can be located in different places in different
# Test-Smoke setups.
my $json_file = File::Spec->catfile($FindBin::Bin, 'perl-current', 'mktest.jsn');
die "Could not locate $json_file" unless -f $json_file;

my $utf8_encoded_json_text = path($json_file)->slurp_utf8;
my $config = decode_json($utf8_encoded_json_text);
my $SHA = $config->{sysinfo}->{git_id};

my $log_file = File::Spec->catfile($FindBin::Bin, 'logs', 'smokecurrent', "log${SHA}.log");
print "log file will be: $log_file\n";

copy($lfile => $log_file) or die "Unable to copy $lfile to $log_file: $!";
open my $OVERALL_LOG, '>>', $log_file or die "Could not open $log_file for appending: $!";
print $OVERALL_LOG POSIX::strftime("[%Y-%m-%d %H:%M:%S%z] ", localtime),
    "Copy($lfile, $log_file): ok\n";
close $OVERALL_LOG or die "Could not close $log_file after writing: $!";

