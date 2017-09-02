use Test::Spec;
use Test::Exception;
use Clone qw( clone );
use JSON;

my $HEADER_PREFIX = 'X-OTRS-EmailFilter-Engine-';

use Email::RuleEngine::Base;

my @nodes = (
    {
        id => 1,
        name => 'name',
        parent => 0,
        rules => [
            {
                expression => [],
                action => { type => 'aaa' },
                child_id => 1
            }
        ]
    },
    {
        id => 2,
        name => 'name2',
        parent => 1,
        rules => [
            {
                expression => [],
                action => { type => 'aaa1' },
                child_id => undef
            }
        ]
    }
);

describe "Email::RuleEngine::Base set_node()" => sub {
    it "fail on empty JSON" => sub {
        throws_ok sub { Email::RuleEngine::Base::set_node() },
            qr/Nodes must be array in JSON format/, "";
    };
    it "fail on not JSON" => sub {
        throws_ok sub { Email::RuleEngine::Base::set_node('test') },
            qr/Nodes must be array in JSON format/, "";
    };
    it "fail on empty array" => sub {
        throws_ok sub { Email::RuleEngine::Base::set_node('[]') },
            qr/Nodes tree isn\'t present/, "";
    };
    it "fail without some fields" => sub {
        my @ns = @{ clone \@nodes };
        map { delete $ns[0]->{$_} } qw(name parent rules);
        throws_ok sub { Email::RuleEngine::Base::set_node( encode_json(\@ns) ) },
            qr/Required node field \'\w+?\' is absent/, "";
    };
    it "fail without rules fields" => sub {
        my @ns = @{ clone \@nodes };
        $ns[0]->{rules} = [ { action => {} } ];
        throws_ok sub { Email::RuleEngine::Base::set_node( encode_json(\@ns) ) },
            qr/Required rule field \'\w+?\' is absent/, "";
    };
    it "fail without action rule type field" => sub {
        Email::RuleEngine::Base->stubs('traverse_expr_check' => 'test');
        throws_ok sub { Email::RuleEngine::Base::set_node( encode_json(\@nodes) ) },
            qr/Expression wrong in node \d+?: test/, "";
    };
    it "on success" => sub {
        Email::RuleEngine::Base->stubs('traverse_expr_check' => undef);
        Email::RuleEngine::Base::set_node( encode_json(\@nodes) );
        is scalar @Email::RuleEngine::Base::nodes, 2;
    };
};

runtests unless caller;
