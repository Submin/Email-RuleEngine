# ABSTRACT: a
package Email::RuleEngine::Condition::Bool;

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

Readonly my $MIN_LIMIT_ARGS => 1;
Readonly my @OPERATORS      => qw( && || ! ^ );

sub new {
    my ( $class ) = @_;
    return bless {}, $class;
}

sub run {
    my ( $self, $op, @expr ) = @_;

    my $success = try {
        croak "Operator '$op' has invalid" unless any { $_ eq $op } @OPERATORS;
        croak "Invalid number of operands" if scalar @expr < $MIN_LIMIT_ARGS;
        1;
    }
    catch {
        update_chain( $_ );
        0;
    };

    return 0 unless $success;

    my @fields;
    foreach my $field ( @expr ) {
        if ( $field =~ m{HeaderExist/(.+)} ) {
            push @fields, defined get_header($1) ? 1 : 0;
        }
        elsif ( $field =~ m{HeaderAbsent/(.+)} ) {
            push @fields, defined get_header($1) ? 0 : 1;
        }
        elsif ( $field =~ m{HeaderTrue/(.+)} ) {
            push @fields, get_header($1) ? 1 : 0;
        }
        elsif ( $field =~ m{HeaderFalse/(.+)} ) {
            push @fields, get_header($1) ? 0 : 1;
        }
        elsif ( $field =~ m{^\d+$} ) {
            push @fields, $field;
        }
    }

    return 0 if scalar @fields < $MIN_LIMIT_ARGS;

    return 0 + eval "$op $fields[0]" if $op eq '!'; # special case
    return 0 + eval join " $op ", @fields;
}

1;

__END__
