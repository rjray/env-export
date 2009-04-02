#!/usr/bin/perl

use strict;
use warnings;
use subs qw(sub_count);

use Test::More;

# TEST SCOPE: These tests exercise the ":split" keyword

plan tests => 5;

# Since there isn't a default behavior with regards to :split, and it doesn't
# carry over like the flags do, that actually simplifies the set of test cases.

$ENV{SPLIT1} = 'a:b:c';
$ENV{SPLIT2} = 'a-b--c';
$ENV{SPLIT3} = 'a--b--c-d';
$ENV{SPLIT4} = '1,2,3';
$ENV{SPLIT5} = '4,5,6';

my $namespace = 'namespace0000';

# 1. Basic
eval qq|
package $namespace;
use Env::Export qw(:split : SPLIT1);
package main;
is(join(':', ${namespace}::SPLIT1()), \$ENV{SPLIT1}, 'Basic :split');
|;
warn "eval fail: $@" if $@;

# 2. Make sure null shows up
$namespace++;
eval qq|
package $namespace;
use Env::Export qw(:split - SPLIT2);
package main;
is(join('-', ${namespace}::SPLIT2()), \$ENV{SPLIT2}, ':split with an empty');
|;
warn "eval fail: $@" if $@;

# 3. Regex test
$namespace++;
eval qq|
package $namespace;
use Env::Export (':split' => qr/-{2,}/, 'SPLIT3');
package main;
is(join('--', ${namespace}::SPLIT3()), \$ENV{SPLIT3}, ':split with regex');
|;
warn "eval fail: $@" if $@;

# 4 & 5. Carries over to a multi-key match
$namespace++;
eval qq|
package $namespace;
use Env::Export (':split' => q{,}, qr/SPLIT[45]/);
package main;
is(join(',', ${namespace}::SPLIT4()), \$ENV{SPLIT4}, ':split carryover [1]');
is(join(',', ${namespace}::SPLIT5()), \$ENV{SPLIT5}, ':split carryover [2]');
|;
warn "eval fail: $@" if $@;

exit;
