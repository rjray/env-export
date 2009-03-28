#!/usr/bin/perl

use strict;
use warnings;
use vars qw($code);

use Test::More;

plan tests => 2;

# Trap the redefine warnings from Perl
$SIG{__WARN__} = sub { 1; };

# This env var will be used to test against
$ENV{PATTERN} = 0;

$code = <<'END_TEMPLATE';
use Env::Export qw(PATTERN);

sub PATTERN () { 1 }

PATTERN();
END_TEMPLATE

ok(eval $code, "Sub declared after module use");

$code = <<'END_TEMPLATE';
sub PATTERN () { 1 }

use Env::Export qw(PATTERN);

PATTERN();
END_TEMPLATE

ok(eval $code, "Sub declared before module use");

exit;
