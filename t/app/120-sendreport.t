#! perl -w
use strict;

use Test::More;
use Test::NoWarnings ();

use Test::Smoke::App::SendReport;
use Test::Smoke::App::Options;
use Test::Smoke::Util::FindHelpers 'get_avail_posters';

use Cwd;
use File::Copy;
use File::Spec;
use File::Temp qw/ tempdir /;

my $opt = 'Test::Smoke::App::Options';

{
    my $poster = (get_avail_posters())[0];
    note("using poster: $poster");

    no warnings 'redefine';
    local *Test::Smoke::Poster::Base::post = sub {
        return 42;
    };
    local *Test::Smoke::App::SendReport::check_for_report_and_json = sub {
        return 1;
    };
    local @ARGV = (
        '--ddir'    => 't/perl',
        '--poster'  => $poster,
        '--verbose' => 2,
        '--nomail',
    );
    my $app = Test::Smoke::App::SendReport->new(
        Test::Smoke::App::Options::sendreport_config(),
    );
    isa_ok($app, 'Test::Smoke::App::SendReport');

    my $report_id = eval { $app->run };
    diag("Error: $@") if $@;
    is($report_id, 42, "->run() returns a report_id");
}

{
    my $tmpdir = tempdir(CLEANUP => 1);

    # locate a report file and a json file,
    # copy them to tempdir,
    # then exercise Test::Smoke::App::SendReport::check_for_report_and_json

    my $cwd = cwd();
    my $dummy_copy_dir = File::Spec->catdir($cwd, 't', 'logs', 'rtc-126010');
    ok(-d $dummy_copy_dir, "Located directory for dummy copy");
    my $jsn_file = File::Spec->catfile($dummy_copy_dir, 'mktest.jsn');
    my $rpt_file = File::Spec->catfile($dummy_copy_dir, 'mktest.rpt');
    ok(-f $jsn_file, "jsn file located for testing");
    ok(-f $rpt_file, "rpt file located for testing");
    copy $jsn_file => $tmpdir or die;
    copy $rpt_file => $tmpdir or die;

    chdir $tmpdir or die "Unable to chdir for testing";
    my $poster = (get_avail_posters())[0];
    note("using poster: $poster");
    no warnings 'redefine';
    local *Test::Smoke::Poster::Base::post = sub {
        return 42;
    };
    local @ARGV = (
        '--ddir'    => $tmpdir,
        '--poster'  => $poster,
        '--verbose' => 2,
        '--nomail',
    );
    my $app = Test::Smoke::App::SendReport->new(
        Test::Smoke::App::Options::sendreport_config(),
    );
    isa_ok($app, 'Test::Smoke::App::SendReport');
    ok($app->check_for_report_and_json(),
        "check_for_report_and_json() returned true value");

    chdir $cwd or die "Unable to change back after testing";
}

{
    # Locate rpt, json and out files.
    # Copy the json and out file to tempdir but "forget" the report file.
    # (out file needed for internal call to regen_report_and_json().
    # Then exercise Test::Smoke::App::SendReport::check_for_report_and_json()

    my $tmpdir = tempdir(CLEANUP => 1);
    my $cwd = cwd();
    my $dummy_copy_dir = File::Spec->catdir($cwd, 't', 'logs', 'rtc-126010');
    ok(-d $dummy_copy_dir, "Located directory for dummy copy");
    my $jsn_file = File::Spec->catfile($dummy_copy_dir, 'mktest.jsn');
    my $rpt_file = File::Spec->catfile($dummy_copy_dir, 'mktest.rpt');
    my $out_file = File::Spec->catfile($dummy_copy_dir, 'mktest.out');
    ok(-f $jsn_file, "jsn file located for testing");
    ok(-f $rpt_file, "rpt file located for testing");
    ok(-f $out_file, "out file located for testing");
    copy $jsn_file => $tmpdir or die;
    copy $out_file => $tmpdir or die;

    chdir $tmpdir or die "Unable to chdir for testing";
    my $poster = (get_avail_posters())[0];
    note("using poster: $poster");
    no warnings 'redefine';
    local *Test::Smoke::Poster::Base::post = sub {
        return 42;
    };
    local @ARGV = (
        '--ddir'    => $tmpdir,
        '--poster'  => $poster,
        '--verbose' => 2,
        '--nomail',
    );
    my $app = Test::Smoke::App::SendReport->new(
        Test::Smoke::App::Options::sendreport_config(),
    );
    isa_ok($app, 'Test::Smoke::App::SendReport');
    ok($app->check_for_report_and_json(),
        "check_for_report_and_json() returned true value");

    chdir $cwd or die "Unable to change back after testing";
}

{
    # Locate rpt, json and out files.
    # Copy the rpt and out files to tempdir but "forget" the jsn file.
    # (out file needed for internal call to regen_report_and_json().
    # Then exercise Test::Smoke::App::SendReport::check_for_report_and_json()

    my $tmpdir = tempdir(CLEANUP => 1);
    my $cwd = cwd();
    my $dummy_copy_dir = File::Spec->catdir($cwd, 't', 'logs', 'rtc-126010');
    ok(-d $dummy_copy_dir, "Located directory for dummy copy");
    my $jsn_file = File::Spec->catfile($dummy_copy_dir, 'mktest.jsn');
    my $rpt_file = File::Spec->catfile($dummy_copy_dir, 'mktest.rpt');
    my $out_file = File::Spec->catfile($dummy_copy_dir, 'mktest.out');
    ok(-f $jsn_file, "jsn file located for testing");
    ok(-f $rpt_file, "rpt file located for testing");
    ok(-f $out_file, "out file located for testing");
    copy $rpt_file => $tmpdir or die;
    copy $out_file => $tmpdir or die;

    chdir $tmpdir or die "Unable to chdir for testing";
    my $poster = (get_avail_posters())[0];
    note("using poster: $poster");
    no warnings 'redefine';
    local *Test::Smoke::Poster::Base::post = sub {
        return 42;
    };
    local @ARGV = (
        '--ddir'    => $tmpdir,
        '--poster'  => $poster,
        '--verbose' => 2,
        '--nomail',
    );
    my $app = Test::Smoke::App::SendReport->new(
        Test::Smoke::App::Options::sendreport_config(),
    );
    isa_ok($app, 'Test::Smoke::App::SendReport');
    ok($app->check_for_report_and_json(),
        "check_for_report_and_json() returned true value");

    chdir $cwd or die "Unable to change back after testing";
}

{
    # Locate rpt, json and out files.
    # Copy the rpt file but "forget" the jsn and out files.
    # The internal call to regen_report_and_json() will die.

    my $tmpdir = tempdir(CLEANUP => 1);
    my $cwd = cwd();
    my $dummy_copy_dir = File::Spec->catdir($cwd, 't', 'logs', 'rtc-126010');
    ok(-d $dummy_copy_dir, "Located directory for dummy copy");
    my $jsn_file = File::Spec->catfile($dummy_copy_dir, 'mktest.jsn');
    my $rpt_file = File::Spec->catfile($dummy_copy_dir, 'mktest.rpt');
    my $out_file = File::Spec->catfile($dummy_copy_dir, 'mktest.out');
    ok(-f $jsn_file, "jsn file located for testing");
    ok(-f $rpt_file, "rpt file located for testing");
    ok(-f $out_file, "out file located for testing");
    copy $rpt_file => $tmpdir or die;

    chdir $tmpdir or die "Unable to chdir for testing";
    my $poster = (get_avail_posters())[0];
    note("using poster: $poster");
    no warnings 'redefine';
    local *Test::Smoke::Poster::Base::post = sub {
        return 42;
    };
    local @ARGV = (
        '--ddir'    => $tmpdir,
        '--poster'  => $poster,
        '--verbose' => 2,
        '--nomail',
    );
    my $app = Test::Smoke::App::SendReport->new(
        Test::Smoke::App::Options::sendreport_config(),
    );
    isa_ok($app, 'Test::Smoke::App::SendReport');
    eval { $app->check_for_report_and_json(); };
    like($@, qr/No smoke results found/,
        "Got expected error message; no outfile with which to run regen_report_and_json"
    );

    chdir $cwd or die "Unable to change back after testing";
}

Test::NoWarnings::had_no_warnings();
$Test::NoWarnings::do_end_test = 0;
done_testing();
