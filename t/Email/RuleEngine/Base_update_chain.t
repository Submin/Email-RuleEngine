use Test::Spec;

my $HEADER_PREFIX = 'X-OTRS-EmailFilter-Engine-';

use Email::RuleEngine::Base;

my $text = 'From root@localhost Tue Dec 17 03:05:07 2013
Return-Path: <root@localhost>
From: Charlie Root <root@localhost>
Test-Header: 1234567890
To: root@localhost
Subject: localhost

Test';

describe "Email::RuleEngine::Base update_chain()" => sub {
    before each => sub {
        Email::RuleEngine::Base::set_object( $text );
    };
    it "before add chain" => sub {
        is $Email::RuleEngine::Base::object->header($HEADER_PREFIX.'chain'), '[]';
    };
    it "after increment" => sub {
        Email::RuleEngine::Base::update_chain('123 test 321');
        is $Email::RuleEngine::Base::object->header($HEADER_PREFIX.'chain'), '["Recursion: 0, 123 test 321"]';
    };
};

runtests unless caller;
