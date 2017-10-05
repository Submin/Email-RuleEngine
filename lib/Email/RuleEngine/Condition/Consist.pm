# ABSTRACT: a
package Email::RuleEngine::Condition::Consist;

use strict;
use warnings;

use 5.006001;

use vars qw($VERSION);

# VERSION

use Carp qw( croak );
use JSON qw( decode_json );
use List::Util qw( any );
use Try::Tiny;
use Readonly;

use Email::RuleEngine::Base qw( get_header update_chain );

Readonly my $STRONG_LIMIT_ARGS => 2;
Readonly my @OPERATORS         => qw( in notin );

sub new ($$) {
    my ( $class, $param ) = @_;

    croak "Operator is missed"
        unless $param->{op};
    croak "Operator '$param->{op}' has invalid"
        unless any { $_ eq $param->{op} } @OPERATORS;

    my $self = {
        coincides => $param->{coincides} || 'any',
        op        => $param->{op}
    };

    return bless $self, $class;
}

sub run {
    my ( $self, @expr ) = @_;

    my $success = try {
        croak "Invalid number of operands" if scalar @expr != $STRONG_LIMIT_ARGS;
        1
    }
    catch {
        update_chain( $_ );
        0;
    };

    return 0 unless $success;

    my $negot = $self->{op} eq 'in' ? '!!' : '!';

    my ( @sub_list, @list );
    foreach my $field ( @expr ) {
        my $value = '';
        if ( $field =~ m{Header/(.+)} ) {
            $value = get_header($1);
        }
        elsif ( $field =~ m{List/(.+)} ) {
            $value = $1;
        }

        my $item = eval { decode_json( $value ) };
        if ( defined $item && ref $item eq 'ARRAY' ) {
            @list = @$item;
        }
        elsif (
            defined $item
            && ref $item eq 'HASH'
            && defined $item->{'List'}
            && ref $item->{'List'} eq 'ARRAY'
        ) {
            @list = @{ $item->{'List'} };
        }
        elsif (
            defined $item
            && ref $item eq 'HASH'
            && defined $item->{'Sublist'}
            && ref $item->{'Sublist'} eq 'ARRAY'
        ) {
            @sub_list = @{ $item->{'Sublist'} };
        }
        else {
            @sub_list = ( $value );
        }
    }

    return 0 unless scalar @sub_list && scalar @list;

    my $result = $self->{coincides} eq 'all' ? 1 : 0;
    my %elems = map { $_ => 1 } @list;
    foreach my $item ( @sub_list ) {
        if ( $self->{coincides} eq 'all' ) {
            $result &= $elems{ $item } || 0;
        }
        else {
            $result |= $elems{ $item } || 0;
        }
    }

    return  0 + eval "$negot $result";
}

1;

__END__
