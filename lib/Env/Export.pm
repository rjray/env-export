###############################################################################
#
# This file copyright (c) 2009 by Randy J. Ray, all rights reserved
#
# Copying and distribution are permitted under the terms of the Artistic
# License 2.0 (http://www.opensource.org/licenses/artistic-license-2.0.php) or
# the GNU LGPL (http://www.opensource.org/licenses/lgpl-2.1.php).
#
###############################################################################
#
#   Description:    Export environment variables as constant subs
#
#   Functions:      import
#
#   Libraries:      Carp
#
#   Environment:    Umm, yeah... that's kind of the point of it all...
#
###############################################################################

package Env::Export;

use 5.006001;
use strict;
use warnings;
use subs qw(import);

use Carp qw(carp croak);

our $VERSION = '0.11';

###############################################################################
#
#   Sub Name:       import
#
#   Description:    Do the actual import work, namespace wrangling, etc.
#
#   Arguments:      NAME      IN/OUT  TYPE      DESCRIPTION
#                   $class    in      scalar    Class we're called in
#                   @patterns in      list      One or more patterns or
#                                                 keywords used to select %ENV
#                                                 keys to export
#
#   Environment:    Yeah
#
#   Returns:        void
#
###############################################################################
sub import
{
    my ($class, @patterns) = @_;

    return unless @patterns; # Nothing to do if they didn't request anything

    my @bad_pats = grep(! /^[A-Za-z_]\w*$/, @patterns);
    if (@bad_pats)
    {
        carp "${class}::import: Removing patterns not legal for identifiers: "
            . "@bad_pats";
        @patterns = grep(! /\W/, @patterns);
    }

    for (@patterns) { $_ = qr/^$_$/ unless (ref($_) eq 'RegExp') }

    my ($calling_pkg) = caller();
    croak("Could not determine caller package")
        if not defined $calling_pkg or $calling_pkg eq '';

    foreach my $envkey (keys %ENV)
    {
        next unless ($envkey =~ /^[A-Za-z_]\w*$/);
        next unless grep($envkey =~ $_, @patterns);

        my $varname = "${calling_pkg}::$envkey";
        my $value = $ENV{$envkey};
        no strict 'refs';
        *$varname = sub () { $value };
    }
}

1;

__END__

=head1 NAME

Env::Export - Export %ENV values as constant subroutines

=head1 SYNOPSIS

    use Env::Export qr/^PAR/;

    # This will fail at compile time if the $ENV{PAR_PROGNAME}
    # environment variable didn't exist:
    print PAR_PROGNAME, "\n";

    # regular constant sub, works fully qualified, too!
    package Foo;
    print main::PAR_PROGNAME, "\n"; 

=head1 DESCRIPTION

This module exports the requested environment variables from C<%ENV> as
constants, represented by subroutines that have the same names as the
specific environment variables.

Specification of the environment values to export may be by explicit name or
by regular expression. Any number of names or patterns may be passed in.

=head2 EXPORT

Any environment variable whose name would be a valid Perl identifier (must
match the pattern C<^[A-Za-z_]\w*$> may be exported this way. No values are
exported by default, all must be explicitly requested. If you request a name
that does not match the above pattern, a warning is issued and the name is
removed from the exports list.

=head1 CAVEATS

You can import all environment variables, if you really want to, by means of:

    use Env::Export qr/./;

=head1 SEE ALSO

L<constant>

=head1 AUTHOR

Randy J. Ray C<< <rjray@blackperl.com> >>

Original idea from a journal posting by Curtis "Ovid" Poe
(C<< <ovid at cpan.org> >>), built on a sample implementation done by
Steffen Mueller, C<< <smueller@cpan.org> >>.

=head1 BUGS

Please report any bugs or feature requests to
C<bug-env-export at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Env-Export>. I will be
notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Env-Export>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Env-Export>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Env-Export>

=item * Search CPAN

L<http://search.cpan.org/dist/Env-Export>

=item * Source code on GitHub

L<http://github.com/rjray/env-export/tree/master>

=back

=head1 COPYRIGHT & LICENSE

This file and the code within are copyright (c) 2009 by Randy J. Ray.

Copying and distribution are permitted under the terms of the Artistic
License 2.0 (L<http://www.opensource.org/licenses/artistic-license-2.0.php>) or
the GNU LGPL 2.1 (L<http://www.opensource.org/licenses/lgpl-2.1.php>).

=cut
