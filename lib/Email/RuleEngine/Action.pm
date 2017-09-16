# ABSTRACT: a
package Email::RuleEngine::Action;

use strict;
use warnings;

use 5.006001;

use vars qw($VERSION);

# VERSION

use Email::RuleEngine::Base qw( update_chain internal_header_set );

use Class::Load qw( load_class );
use Carp qw( croak );

use Exporter 'import';

our @EXPORT_OK = qw( action );

sub action {
    my $rule = shift;

    croak "Undefined action type" unless $rule->{action}->{type};

    my $class = 'Email::RuleEngine::Action::'.ucfirst lc $rule->{action}->{type};

    load_class $class;

    my $action = $class->new();
    $action->run( $rule );

    my $next_node = $rule->{child_id} // '';

    internal_header_set({ 'node_id' => $next_node });

    update_chain("object processed by node: '$rule->{node_name}' "
        . "(id: $rule->{node_id}), rule: '$rule->{action}->{name}' , next node: '$next_node'");
}

1;

__END__