# ABSTRACT: a
package Email::RuleEngine::Action::Mark;

use strict;
use warnings;

use 5.010;

use vars qw($VERSION);

# VERSION

use Email::RuleEngine::Base qw( set_header );

sub new {
    my ( $class ) = @_;
    return bless {}, $class;
}

sub run {
    my ( $self, $rule ) = @_;

    my %fields = %{ $rule->{action}->{fields} || {} };

    set_header( \%fields ) if %fields;
}

1;

__END__
