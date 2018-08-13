#! perl -w
use strict;

use Test::More;
use Test::NoWarnings ();

use Test::Smoke::App::Archiver;
use Test::Smoke::App::Options;
use Data::Dumper;
use File::Spec;
use File::Temp qw(tempdir);

{
    my $tdir = tempdir(CLEANUP => 1);
    my $adir = File::Spec->catdir($tdir, 'logs', 'smokecurrent');
    my $ddir = File::Spec->catdir('.', 't', 'logs', 'rtc-126010');
    ok(-d $ddir, "Located $ddir for testing");
    my $lfile = File::Spec->catfile($ddir, 'smokecurrent.log');
    ok(-f $lfile, "Located $lfile for testing");
    my @mktest_filetypes = qw/ jsn rpt out /;
    for my $f (@mktest_filetypes) {
        my $g = File::Spec->catfile($ddir, "mktest.$f");
        ok(-f $g, "Located $g for testing");
    }

    # adir => $archive_destination_directory
    # ddir => $smoke_destination_directory
    local @ARGV = ('--archive', '-v' => 2,
        '--adir'    => $adir,
        '--ddir'    => $ddir,
        '--lfile'   => $lfile,
    );
    my $app = Test::Smoke::App::Archiver->new(
        Test::Smoke::App::Options->archiver_config(),
    );
    isa_ok($app, 'Test::Smoke::App::Archiver');

    no warnings 'redefine';
    my $files = { map {$_ => 1} ((qw/mktest.jsn mktest.out mktest.rpt/), $lfile) };
print STDERR "VVV:\n";
    my $result = $app->run;
    print STDERR "WWW: @$result\n";
    my $got = { map {$_ => 1} @{$result} };
    is_deeply($got, $files, "List of files archived") or print Dumper [ $got, $files ];
}

Test::NoWarnings::had_no_warnings();
$Test::NoWarnings::do_end_test = 0;
done_testing();
