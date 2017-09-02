use Test::Spec;
use Test::Exception;

use Email::RuleEngine::Base;

my $text = 'From root@localhost Tue Dec 17 03:05:07 2013
Return-Path: <root@localhost>
From: Charlie Root <root@localhost>
Test-Header: 1234567890
To: root@localhost
Subject: localhost

Test';

describe "Email::RuleEngine::Base set_object()" => sub {
    it "fail on without any data" => sub {
        throws_ok sub { Email::RuleEngine::Base::set_object() },
            qr/Email object is undefined/, "";
    };
    it "success" => sub {
        Email::RuleEngine::Base::set_object( $text );
        is ref $Email::RuleEngine::Base::object, 'Email::Simple';
    };
};

runtests unless caller;
