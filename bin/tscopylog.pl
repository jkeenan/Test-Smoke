#!/home/jkeenan/perl5/perlbrew/perls/perl-5.28.0/bin/perl -w
use strict;

use File::Spec::Functions;
use FindBin;
use lib $FindBin::Bin;
use lib catdir($FindBin::Bin, 'lib');
use lib catdir($FindBin::Bin, updir(), 'lib');

use Test::Smoke::App::Options;
use Test::Smoke::App::SmokePerl;
use File::Copy;
use File::Spec;
use JSON;
use Path::Tiny ();
use POSIX ();
use Data::Dump qw(dd pp);

my $app = Test::Smoke::App::SmokePerl->new(
    Test::Smoke::App::Options->smokeperl_config()
);

if (my $error = $app->configfile_error) {
    die "$error\n";
}
#dd($app);
#dd([ keys %$app ]);

my $jsnfile = File::Spec->catfile($app->option('ddir'), $app->option('jsnfile'));
die "Could not locate mktest.json" unless -f $jsnfile;

my $adir = $app->option('adir');
die "Could not logs/smokecurrent directory" unless -d $adir;

my $lfile = $app->option('lfile');
die "Could not locate smokecurrent.log" unless -f $lfile;

my $utf8_encoded_json_text = Path::Tiny::path($jsnfile)->slurp_utf8;
my $config = decode_json($utf8_encoded_json_text);
my $SHA = $config->{sysinfo}->{git_id};

my $log_file = File::Spec->catfile( $adir, "log${SHA}.log" );
print "log file will be: $log_file\n";

copy($lfile => $log_file) or die "Unable to copy $lfile to $log_file: $!";
open my $OVERALL_LOG, '>>', $log_file or die "Could not open $log_file for appending: $!";
print $OVERALL_LOG POSIX::strftime("[%Y-%m-%d %H:%M:%S%z] ", localtime),
    "Copy($lfile, $log_file): ok\n";
close $OVERALL_LOG or die "Could not close $log_file after writing: $!";
