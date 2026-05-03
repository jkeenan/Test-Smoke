#! /usr/perl/perl -w
use strict;

use Data::Dumper;
use File::Temp qw/ tempdir /;
our $conf;

use Test::More;
BEGIN { use_ok( 'Test::Smoke' ) }

note("\$Test::Smoke::VERSION: $Test::Smoke::VERSION");

ok( defined &read_config, "read_config() is exported" );

my $test = { ddir => '../' };
my $tdir = tempdir(CLEANUP => 1);
my $prefix = 'smokecurrent';

{
    note("Simplest case: actual file named 'smokecurrent_config'");

    my $config_basename =  "${prefix}_config";
    my $config_path = File::Spec->catfile($tdir, $config_basename);

    open my $FH1, '>', $config_path or die "Cannot write file: $!";
    print $FH1 Data::Dumper->Dump( [$test], ['conf'] );
    close $FH1 or die "Cannot close file: $!";

    ok( read_config( $config_path ), "read_config($config_path)" );
    is( Test::Smoke->config_error, undef, "No errors" );
    is_deeply( $conf, $test, "Configuration compares" );
}

{
    note("No explicit argument to read_config() and no actual config file");

    my $rv = read_config();
    ok(! defined $rv, "read_config returned undefined value");
    my $error = Test::Smoke::config_error();
    ok(length($error), "non-zero length string returned for config error");
    like($error, qr/^Can't locate smokecurrent_config/s,
        "Got expected configuration error message");
}

{
    note("Argument to read_config is empty string; no actual config file");

    my $rv = read_config('');
    ok(! defined $rv, "read_config returned undefined value");
    my $error = Test::Smoke::config_error();
    ok(length($error), "non-zero length string returned for config error");
    like($error, qr/^Can't locate smokecurrent_config/s,
        "Got expected configuration error message");
}

{
    note("Explicit argument to read_config,\n\tactual file whose name does not end in '_config'");

    my $config_basename =  "ultra";
    my $config_path = File::Spec->catfile($tdir, $config_basename);

    open my $FH2, '>', $config_path or die "Cannot write file: $!";
    print $FH2 Data::Dumper->Dump( [$test], ['conf'] );
    close $FH2 or die "Cannot close file: $!";

    ok( read_config( $config_path ), "read_config($config_path)" );
    is( Test::Smoke->config_error, undef, "No errors" );
    is_deeply( $conf, $test, "Configuration compares" );
}

undef $conf;

my $config_short = File::Spec->catfile( $tdir, $prefix );
ok( read_config( $config_short ), "read_config($config_short)" );
is( Test::Smoke->config_error, undef, "No errors" );
is_deeply( $conf, $test, "Configuration compares after reloading" );

done_testing();

