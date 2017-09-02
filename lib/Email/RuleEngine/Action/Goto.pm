# ABSTRACT: a
package Email::RuleEngine::Action::Goto;

use strict;
use warnings;

use 5.006001;

use vars qw($VERSION);

# VERSION

sub new {
    my ( $class ) = @_;
    return bless {}, $class;
}

sub run { 1; }

1;

__END__
