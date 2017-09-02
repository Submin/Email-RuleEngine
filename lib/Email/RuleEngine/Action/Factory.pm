# ABSTRACT: a
package Email::RuleEngine::Action::Factory;

use strict;
use warnings;

use 5.006001;

use vars qw($VERSION);

# VERSION

use Readonly;
use Class::Load qw( load_class );
use Carp qw( croak );

Readonly our %ACTION_PROVIDERS => (
    'mark'    => 'Email::RuleEngine::Action::Mark',
    'kill'    => 'Email::RuleEngine::Action::Kill',
    'goto'    => 'Email::RuleEngine::Action::Goto',
    'resolve' => 'Email::RuleEngine::Action::Resolve',
    'extract' => 'Email::RuleEngine::Action::Extract',
);

sub create {
    my $type = shift;

    croak "Undefined action type" unless $type;

    my $class = $ACTION_PROVIDERS{ lc $type };

    croak "Unknown action type" unless $class;

    load_class $class;

    return $class->new();
}

1;

__END__
