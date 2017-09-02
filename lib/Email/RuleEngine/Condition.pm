# ABSTRACT: Root condition module
package Email::RuleEngine::Condition;

use strict;
use warnings;
no warnings 'recursion';

use 5.006001;

use vars qw($VERSION);

# VERSION

use Email::RuleEngine::Condition::Factory;

use Exporter 'import';

our @EXPORT_OK = qw( traverse_build );

=method traverse_build()
=cut

sub traverse_build {
    my $thing = shift;

    my @expr = ();
    foreach my $sub ( @{ $thing->{expression} } ) {
        push @expr, ref $sub eq 'HASH' ? traverse_build( $sub ) : $sub;
    }

    return build( $thing, @expr );
}

sub build {
    my ( $thing, @expr ) = @_;

    my $condition = Email::RuleEngine::Condition::Factory::create( $thing->{type} );
    return $condition->run( $thing->{op}, @expr );
}

1;

__END__
