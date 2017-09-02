# ABSTRACT: Tool for stream email processing
package Email::RuleEngine;

use strict;
use warnings;
no warnings 'recursion';

use 5.006001;

use vars qw($VERSION);

# VERSION

use Try::Tiny;

use Email::RuleEngine::Condition qw( traverse_build );
use Email::RuleEngine::Action qw( action );
use Email::RuleEngine::Base qw(
    inc_recursion
    set_object
    get_object
    set_node
    get_node
    check
);

=method run

Start processing an email according to the rules

Returns:  Email::Simple object

=cut

sub run {
    my ( %param ) = @_;

    try {
        set_object( $param{text} || '' );
        set_node( $param{nodes} || '' );
        _loop();
        return get_object();
    }
    catch {
        return $_;
    }
}

=method _loop

Main loop processing

Returns: void

=cut

sub _loop {
    return unless check();

    inc_recursion();

    my $node = get_node();

    foreach my $rule ( @{ $node->{rules} } ) {
        map { $rule->{ 'node_' . $_ } = $node->{$_} } qw( id name );
        # calculate rule condition recursive and if it true to do suitable action
        action( $rule ) and last if traverse_build( $rule->{expression} );
    }

    $node = undef;

    _loop();
}

1;

__END__
