# ABSTRACT: a
package Email::RuleEngine::Action::Kill;

use strict;
use warnings;

use 5.006001;

use vars qw($VERSION);

# VERSION

use Email::RuleEngine::Base qw( internal_header_set );

sub new {
    my ( $class ) = @_;
    return bless {}, $class;
}

sub run {
    my ( $self, $rule ) = @_;

    my $data = {
        'status'  => 'FINISHED',
        'message' => 'Processing was killed directly'
    };

    my $fields = $rule->{action}->{fields};
    if ( defined $fields && ref $fields eq 'HASH' ) {
        map { $data->{$_} = $fields->{$_} } keys %$fields;
    }

    internal_header_set( $data );
}

1;

__END__
