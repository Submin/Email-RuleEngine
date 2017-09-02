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

describe "Email::RuleEngine::Base inc_recursion()" => sub {
    before each => sub {
        Email::RuleEngine::Base::set_object( $text );
    };
    it "before increment" => sub {
        is $Email::RuleEngine::Base::object->header($HEADER_PREFIX.'recursion'), 0;
    };
    it "after increment" => sub {
        Email::RuleEngine::Base::inc_recursion();
        is $Email::RuleEngine::Base::object->header($HEADER_PREFIX.'recursion'), 1;
    };
};

runtests unless caller;
