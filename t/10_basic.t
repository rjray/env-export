#!/usr/bin/perl

use strict;
use warnings;
use vars qw($TEMPLATE $instance @all_env);

use Test::More;

@all_env = sort grep(/^[A-Za-z_]\w*$/, keys %ENV);

plan tests => scalar @all_env;

$TEMPLATE = <<'END_TEMPLATE';
use Env::Export qw(PATTERN);

PATTERN;
END_TEMPLATE

for my $test (@all_env)
{
    ($instance = $TEMPLATE) =~ s/PATTERN/$test/g;

    is(eval $instance, $ENV{$test}, "Import of $test");
}

exit;
