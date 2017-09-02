# ABSTRACT: a
package Email::RuleEngine::Condition::Subnet;

use strict;
use warnings;

use 5.006001;

use vars qw($VERSION);

# VERSION

use Carp qw( croak );
use Net::Subnet qw( subnet_matcher );
use JSON qw( decode_json );
use List::Util qw( any );
use Try::Tiny;
use Readonly;
use Regexp::IPv6 qw( $IPv6_re );

use Email::RuleEngine::Base qw( get_header update_chain );

Readonly my $STRONG_LIMIT_ARGS => 2;
Readonly my @OPERATORS         => qw( in notin );
Readonly my $REGEXP_IP4        => '(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})';
Readonly my $REGEXP_IP6        => "($IPv6_re)";

sub new {
    my ( $class, %param ) = @_;

    my $self = {};

    $self->{'coincides'} = $param{'coincides'} || 'any';

    return bless $self, $class;
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

    my $negot = $op eq 'in' ? '!!' : '!';

    my ( @addr, @subnet );
    foreach my $field ( @expr ) {
        my $value = '';
        if ( $field =~ m{Header/(.+)} ) {
            $value = get_header($1);
        }
        elsif ( $field =~ m{Subnet/(.+)} ) {
            $value = $1;
        }

        my $item = eval { decode_json( $value ) };
        # if field mark as Subnet and it's json string
        if ( defined $item && ref $item eq 'ARRAY' && !@subnet ) {
            @subnet = @$item;
        }
        # if field mark as header and consists a subnets list
        elsif (
            defined $item
            && ref $item eq 'HASH'
            && defined $item->{'Subnet'}
            && ref $item->{'Subnet'} eq 'ARRAY'
            && !@subnet
        ) {
            @subnet = @{ $item->{'Subnet'} };
        }
        # if field mark as header and consists an addresses list
        elsif (
            defined $item
            && ref $item eq 'HASH'
            && defined $item->{'Addr'}
            && ref $item->{'Addr'} eq 'ARRAY'
            && !@addr
        ) {
            @addr = @{ $item->{'Addr'} };
        }
        # if field mark as header and string it isn't json but it is an ip address
        elsif (
            $value
            && !@addr
            && (
                $value =~ m{^$REGEXP_IP4$}
                || $value =~ m{^$REGEXP_IP6$}
            )
        ) {
            @addr = ( $value );
        }
    }

    return 0 unless scalar @addr && scalar @subnet;

    my $matcher = subnet_matcher @subnet;

    my $result = $self->{'coincides'} eq 'all' ? 1 : 0;
    foreach my $item ( @addr ) {
        if ( $self->{'coincides'} eq 'all' ) {
            $result &= $matcher->( $item );
        }
        else {
            $result |= $matcher->( $item );
        }
    }

    return 0 + eval "$negot $result";
}

1;

__END__
