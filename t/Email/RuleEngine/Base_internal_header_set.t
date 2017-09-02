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

describe "Email::RuleEngine::Base internal_header_set()" => sub {
    before each => sub {
        Email::RuleEngine::Base::set_object( $text );
    };
    it "success" => sub {
        my $val = 123;
        Email::RuleEngine::Base::internal_header_set({test => $val});
        is $Email::RuleEngine::Base::object->header($HEADER_PREFIX.'test'), $val;
    };
};

runtests unless caller;
