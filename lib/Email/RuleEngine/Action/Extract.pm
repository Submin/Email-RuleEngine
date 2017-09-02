# ABSTRACT: a
package Email::RuleEngine::Action::Extract;

use strict;
use warnings;

use 5.010;

use vars qw($VERSION);

# VERSION

use Readonly;
use JSON qw( encode_json );
use Regexp::IPv6 qw( $IPv6_re );

use Email::RuleEngine::Base qw( set_header get_header );

Readonly my $REGEXP_IP4 => '(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})';
Readonly my $REGEXP_IP6 => "($IPv6_re)";
Readonly my $REGEXP_URL => 'https?:\/\/([\w+|.|-]+)';

sub new {
    my ( $class ) = @_;
    return bless {}, $class;
}

sub run {
    my ( $self, $rule ) = @_;

    my %fields = %{ $rule->{action}->{fields} || {} };

    if ( $rule->{action}->{options} && ref $rule->{action}->{options} eq 'HASH' ) {
        foreach my $field ( keys %fields ) {

            my $options = $rule->{action}->{options}->{$field};
            my $type = $options && $options->{type} ? $options->{type} : 'copy';

            my $field_val = delete $fields{ $field };
            next if $type eq 'regexp' && !defined $field_val;

            my $header = get_header( $field );
            next unless defined $header;

            given ( $type ) {
                when ( 'regexp' ) {
                    my @result = ( $header =~ /$field_val/gsmax );
                    $fields{ $field } = encode_json( \@result );
                }
                when ( 'ip' ) {
                    my @result = ( $header =~ m{$REGEXP_IP4}gsmax, $header =~ m{$REGEXP_IP6}gsmax );
                    $fields{ $field } = encode_json( \@result );
                }
                when ( 'ipv4' ) {
                    my @result = ( $header =~ m{$REGEXP_IP4}gsmax );
                    $fields{ $field } = encode_json( \@result );
                }
                when ( 'ipv6' ) {
                    my @result = ( $header =~ m{$REGEXP_IP6}gsmax );
                    $fields{ $field } = encode_json( \@result );
                }
                when ( 'dname' ) {
                    my @result = ( $header =~ m{$REGEXP_URL}gsmax );
                    $fields{ $field } = encode_json( \@result );
                }
                default {
                    $fields{ $field } = $header;
                }
            }
        }
    }

    set_header( \%fields ) if %fields;
}

1;

__END__
