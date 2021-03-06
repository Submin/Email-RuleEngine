# ABSTRACT: a
package Email::RuleEngine::Condition::Cmp;

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

Readonly my $STRONG_LIMIT_ARGS => 2;
Readonly my @STR_OPERATORS     => qw( eq ne lt gt le le );
Readonly my @NUM_OPERATORS     => qw( == != < > <= => );

sub new {
    my ( $class ) = @_;
    return bless {}, $class;
}

sub run {
    my ( $self, $op, @expr ) = @_;

    my ( $str_cmp, $num_cmp );

    my $success = try {
        croak "Condition operator is required" unless $op;

        $str_cmp = any { $_ eq $op } @STR_OPERATORS;
        $num_cmp = any { $_ eq $op } @NUM_OPERATORS;

        croak "Operator '$op' has invalid" unless $str_cmp || $num_cmp;
        croak "Invalid number of operands" if scalar @expr != $STRONG_LIMIT_ARGS;
        1;
    }
    catch {
        update_chain( $_ );
        0;
    };

    return 0 unless $success;

    my @fields;
    foreach my $field ( @expr ) {
        my $value;

        if ( $field =~ m{Header/(.+)} ) {
            $value = get_header($1);
        }
        elsif ( $field =~ m{Value/(.+)} ) {
            $value = $1;
        }

        push @fields, defined $value ? $str_cmp ? "'$value'" : $value : undef;
    }

    return 0 if scalar( grep { defined $_ } @fields ) != $STRONG_LIMIT_ARGS;
    return 0 + eval join " $op ", @fields;
}

1;

__END__
