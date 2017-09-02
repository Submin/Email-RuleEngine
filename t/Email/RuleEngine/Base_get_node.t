use Test::Spec;
use Test::Exception;
use Email::Simple;

my $HEADER_PREFIX = 'X-OTRS-EmailFilter-Engine-';

use Email::RuleEngine::Base;

my $text = 'From root@localhost Tue Dec 17 03:05:07 2013
Return-Path: <root@localhost>
From: Charlie Root <root@localhost>
Test-Header: 1234567890
To: root@localhost
Subject: localhost

Test';

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

describe "Email::RuleEngine::Base get_node()" => sub {
    before each => sub {
        $Email::RuleEngine::Base::object = Email::Simple->new( $text );
        @Email::RuleEngine::Base::nodes = @nodes;
    };
    it "fail on undefined node_id" => sub {
        throws_ok sub { Email::RuleEngine::Base::get_node() },
            qr/Node ID must be a integer/, "";
    };
    it "fail on incorrect node_id" => sub {
        $Email::RuleEngine::Base::object->header_set($HEADER_PREFIX . 'node_id', 'qw');
        throws_ok sub { Email::RuleEngine::Base::get_node() },
            qr/Node ID must be a integer/, "";
    };
    it "fail on absent node with some correct ID" => sub {
        $Email::RuleEngine::Base::object->header_set($HEADER_PREFIX . 'node_id', 21);
        throws_ok sub { Email::RuleEngine::Base::get_node() },
            qr/Node with id \d+ don\'t exists/, "";
    };
    it "on success" => sub {
        $Email::RuleEngine::Base::object->header_set($HEADER_PREFIX . 'node_id', 2);
        cmp_deeply Email::RuleEngine::Base::get_node(), $nodes[1];
    };
};

runtests unless caller;
