# ABSTRACT: a
package Email::RuleEngine::Condition::Regexp;

use strict;
use warnings;

use 5.006001;

use vars qw($VERSION);

# VERSION

use Carp qw( croak );
use List::Util qw( any );
use Try::Tiny;
use Readonly;

use Email::RuleEngine::Base qw( get_header update_chain );

Readonly my $STRONG_LIMIT_ARGS  => 2;
Readonly my @OPERATORS          => qw( !~ =~ );

sub new {
    my ( $class ) = @_;
    return bless {}, $class;
}

sub run {
    my ( $self, $op, @expr ) = @_;

    my $success = try {
        croak "Operator '$op' has invalid" unless any { $_ eq $op } @OPERATORS;
        croak "Invalid number of operands" if scalar @expr != $STRONG_LIMIT_ARGS;
        1;
    }
    catch {
        update_chain( $_ );
        0;
    };

    return 0 unless $success;

    my ( $subject, $regexp );
    foreach my $field ( @expr ) {
        if ( $field =~ m{Header/(.+)} ) {
            my $val = get_header($1);
            $subject = defined $val ? $val : undef;
        }
        elsif ( $field =~ m{Regexp/(.+)} ) {
            $regexp = qr($1);
        }
    }

    return 0 unless defined $subject && defined $regexp;

    return 0 + eval "'$subject' $op m/${regexp}/smxa";
}

1;

__END__
