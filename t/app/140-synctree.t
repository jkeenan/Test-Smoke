#! perl -w
use strict;

use Test::More;
use Test::NoWarnings ();

use Cwd 'abs_path';
use Test::Smoke::App::SyncTree;
use Test::Smoke::App::Options;
my $opt = 'Test::Smoke::App::Options';

# The syncers should be tested individually...
{
    my $ddir = abs_path('t');

    local @ARGV = ('--syncer' => 'git', '--ddir', $ddir, '-v' => 0);
    my $app = Test::Smoke::App::SyncTree->new(
        $opt->synctree_config(),
    );
    isa_ok($app, 'Test::Smoke::App::SyncTree');

    no warnings 'redefine';
    my $versionish = 'v5.42.42-gFEDCBA9';
    local *Test::Smoke::Syncer::Git::sync = sub { return $versionish };
    my $result = $app->run();
    is($result, $versionish, "result (patch-version) found: $result");
}

Test::NoWarnings::had_no_warnings();
$Test::NoWarnings::do_end_test = 0;
done_testing();
