# ABSTRACT: Parse the Subject, extract ip and dnames and resolve it
package Email::RuleEngine::Action::Resolve;

use strict;
use warnings;

use 5.006001;

use vars qw($VERSION);

# VERSION

use utf8;
use Net::DNS;
use Data::Validate::Domain qw( is_domain );
use Net::IDN::Encode  qw( domain_to_ascii );
use Carp qw( croak );
use JSON qw( encode_json );

use Email::RuleEngine::Base qw( set_header get_header );

sub new {
    my ( $class ) = @_;
    return bless {}, $class;
}

sub run {
    my ( $self, $rule ) = @_;

    my %fields = %{ $rule->{action}->{fields} || {} };

    my %config = ( $rule->{action}->{options} && ref $rule->{action}->{options} eq 'HASH' )
        ? %{ $rule->{action}->{options}->{config} || {} } : ();

    my $resolver = new Net::DNS::Resolver( %config );

    foreach my $field ( keys %fields ) {
        delete $fields{ $field };

        my $header  = get_header( $field );
        my @domains = ( eval { decode_json( $header ) } || $header );

        foreach my $domain (@domains ) {
            next unless defined $domain || is_domain(domain_to_ascii($domain, UseSTD3ASCIIRules => 0));
            if ( my $reply = $resolver->search( $domain, 'A' ) ) {
                my @resolved = ();
                map { push @resolved, $_->address } $reply->answer;
                $fields{ $field } = encode_json( \@resolved );
            }
        }

    }

    set_header( \%fields ) if %fields;
}

1;

__END__
