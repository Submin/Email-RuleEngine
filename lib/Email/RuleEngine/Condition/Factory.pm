# ABSTRACT: a
package Email::RuleEngine::Condition::Factory;

use strict;
use warnings;

use 5.006001;

use vars qw($VERSION);

# VERSION

use Carp qw( croak );
use Class::Load qw( load_class );
use Readonly;

Readonly our %CONDITION_PROVIDERS => (
     'bool'     => 'Email::RuleEngine::Condition::Bool',
     'cmp'      => 'Email::RuleEngine::Condition::Cmp',
     'consist'  => 'Email::RuleEngine::Condition::Consist',
     'regexp'   => 'Email::RuleEngine::Condition::Regexp',
     'subnet'   => 'Email::RuleEngine::Condition::Subnet'
);

sub create {
    my $type = shift;

    croak "Undefined condition type" unless $type;

    my $class = $CONDITION_PROVIDERS{ lc $type };

    croak "Unknown condition type" unless $class;

    load_class $class;

    return $class->new();
}

1;

__END__
