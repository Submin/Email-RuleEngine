use Test::Spec;
use Test::Exception;

my $HEADER_PREFIX = 'X-OTRS-EmailFilter-Engine-';

use Email::RuleEngine::Base;

my $text = 'From root@localhost Tue Dec 17 03:05:07 2013
Return-Path: <root@localhost>
Received: from localhost (localhost [127.0.0.1])
From: Charlie Root <root@localhost>
Test-Header: 1234567890
To: root@localhost
Subject: localhost

Test';

describe "Email::RuleEngine::Base check()" => sub {
    before each => sub {
        Email::RuleEngine::Base::set_object( $text );
    };
    it "fail on route lost" => sub {
        $Email::RuleEngine::Base::object->header_set( $HEADER_PREFIX . 'node_id', undef );
        throws_ok sub { Email::RuleEngine::Base::check() },
            qr/Route is lost/, "";
    };
    it "success on with reach max recursion depth" => sub {
        $Email::RuleEngine::Base::object->header_set( $HEADER_PREFIX . 'recursion', 1_000 );
        is Email::RuleEngine::Base::check(), 0;
    };
    it "success on processing continue" => sub {
        $Email::RuleEngine::Base::object->header_set( $HEADER_PREFIX . 'status', 'IN_PROGRESS' );
        is Email::RuleEngine::Base::check(), 1;
    };
    it "success on processing finished" => sub {
        $Email::RuleEngine::Base::object->header_set( $HEADER_PREFIX . 'status', 'FINISHED' );
        is Email::RuleEngine::Base::check(), 0;
    };
};

runtests unless caller;
