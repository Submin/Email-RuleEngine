# ABSTRACT: a
package Email::RuleEngine::Base;

use warnings;
use strict;

use 5.006001;

use vars qw($VERSION);

# VERSION

use Class::Load qw( load_class );
use Carp qw( croak );
use Try::Tiny;
use Email::Simple;
use Clone qw( clone );
use JSON qw( encode_json decode_json );
use Readonly;

Readonly my %STATUS => (
    BEGIN    => 'BEGIN',
    PROGRESS => 'IN_PROGRESS',
    FINISHED => 'FINISHED',
);

Readonly my $AUTOFINISH_RULE => {
    expression => { expression => [ 1 ], type => 'BOOL', op => '&&' },
    action     => { type => 'KILL', name => 'AUTOFINISH', fields => { message => 'Autofinishing' } },
    child_id   => 0
};

Readonly my $MAX_RECURSION_DEPTH => 1_000;
Readonly my $INT_HEADER_PREFIX   => 'X-OTRS-EmailFilter-Engine-';
Readonly my $MOD_NAMESPACE       => 'Email::RuleEngine';

Readonly my @NODE_FIELDS         => qw( id name parent rules );
Readonly my @RULE_FIELDS         => qw( expression action child_id );
Readonly my @EXPR_FIELDS         => qw( expression type op );

use Exporter 'import';

our @EXPORT_OK = qw(
    internal_header_set
    inc_recursion
    update_chain
    set_object
    get_object
    set_header
    get_header
    get_body
    set_node
    get_node
    check
    create
);

our ( $object, @nodes );

sub get_object {
    return clone $object;
}

sub set_object {
    my $text = shift;

    croak "Email object is undefined" unless $text;

    my $data = Email::Simple->new( $text );

    $data->header_set( $INT_HEADER_PREFIX . 'node_id', 0 );
    $data->header_set( $INT_HEADER_PREFIX . 'recursion', 0 );
    $data->header_set( $INT_HEADER_PREFIX . 'status', $STATUS{BEGIN} );
    $data->header_set( $INT_HEADER_PREFIX . 'chain', '[]' );

    $object = $data;
}

sub internal_header_set {
    my $headers = shift;

    set_header({
        map { $INT_HEADER_PREFIX . $_ => $headers->{$_} } keys %$headers
    });
}

sub set_header {
    my $headers = shift;

    foreach my $header ( keys %$headers ) {
        $object->header_set( $header, $headers->{$header} );
    }
}

sub get_header {
    my $header = shift;

    return defined $header ? $object->header( $header ) : undef;
}

sub get_body {
    return $object->body;
}

sub get_node {
    my $node_id = $object->header( $INT_HEADER_PREFIX . 'node_id' );

    croak "Node ID must be a integer" unless defined $node_id && $node_id =~ /^\d+$/;

    my ( $node ) = grep { $_->{id} == $node_id } @nodes;

    croak "Node with id $node_id don't exists" unless defined $node;

    return clone $node;
}

sub set_node {
    my $data = eval { decode_json( shift ) };

    croak "Nodes must be array in JSON format"
        unless defined $data && ref $data eq 'ARRAY';
    croak "Nodes tree isn't present" unless scalar @$data;

    foreach my $node ( @$data ) {
        map { croak "Required node field '$_' is absent" unless exists $node->{$_} } @NODE_FIELDS;
        foreach my $rule ( @{ $node->{rules} } ) {
            map { croak "Required rule field '$_' is absent" unless exists $rule->{$_} } @RULE_FIELDS;
            croak "Required action rule field 'type' is absent" unless $rule->{action}->{type};

            my $error = traverse_expr_check( $rule->{expression} );
            croak "Expression wrong in node $node->{id}: $error" if $error;
        }

        push @{ $node->{rules} }, clone $AUTOFINISH_RULE;
    }

    my %seen;
    map { $seen{ $_->{id} }++ && croak "Node with ID: '$_->{id}' already defined" } @$data;

    @nodes = @$data;
}

sub check {
    croak "Route is lost" unless defined $object->header( $INT_HEADER_PREFIX . 'node_id' );

    if ( $object->header( $INT_HEADER_PREFIX . 'recursion' ) >= $MAX_RECURSION_DEPTH ) {
        $object->header_set( $INT_HEADER_PREFIX . 'status', $STATUS{FINISHED} );
        $object->header_set( $INT_HEADER_PREFIX . 'message', 'Reached maximum recursion depth' );
    }

    return $object->header( $INT_HEADER_PREFIX . 'status' ) eq $STATUS{FINISHED} ? 0 : 1;
}

sub traverse_expr_check {
    my $thing = shift;

    try {
        croak "Expression is undefined" unless $thing;

        croak "Expression must be a hash ref" unless ref $thing eq 'HASH';

        map { croak "Required expression field '$_' is absent" unless $thing->{$_} } @EXPR_FIELDS;

        croak "Condition field 'expression' must be array ref"
            unless ref $thing->{expression} eq 'ARRAY';

        croak "Condition field 'expression' must from consist one or more items"
            unless scalar @{ $thing->{expression} } >= 1;

        foreach my $sub ( @{ $thing->{expression} } ) {
            traverse_expr_check( $sub ) if ref $sub eq 'HASH';
        }

        return;
    }
    catch {
        return $_;
    }
}

sub update_chain {
    my $msg = shift || '';

    my $recursion = $object->header( $INT_HEADER_PREFIX . 'recursion' );
    my $chain = decode_json( $object->header( $INT_HEADER_PREFIX . 'chain' ) );
    push @$chain, "Recursion: $recursion, $msg";

    $object->header_set( $INT_HEADER_PREFIX . 'chain', encode_json( $chain ) );
}

# Increment recursion count
sub inc_recursion {
    my $recursion = $object->header( $INT_HEADER_PREFIX . 'recursion' );
    $object->header_set( $INT_HEADER_PREFIX . 'recursion', ++$recursion );
}

sub create ($;$) {
    my ( $type, $param ) = @_;

    my ($namespace, $entity) = caller =~ /^(.+)::(.+?)$/;

    croak "Invalid namespace"
        unless $namespace ne $MOD_NAMESPACE;

    croak "$entity is unknown entity"
        unless $entity ~~ ['Acton', 'Condition'];

    my $class = $namespace . '::' . $entity . '::' . ucfirst lc $type;

    load_class $class;

    while ( my ($k, $v) = each map { $_ => eval { $class->can($_) } } qw(new run) ) {
        croak "$$class is missing methods: $k. See documentation" unless $v;
    }

    return $class->new( $param || {} );
}

1;

__END__