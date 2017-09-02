use Test::Spec;
use Email::Simple;

use Email::RuleEngine::Base;

my $text = 'From root@localhost Tue Dec 17 03:05:07 2013
Return-Path: <root@localhost>
From: Charlie Root <root@localhost>
Test-Header: 1234567890
To: root@localhost
Subject: localhost

Test';

describe "Email::RuleEngine::Base get_header()" => sub {
    before each => sub {
        $Email::RuleEngine::Base::object = Email::Simple->new( $text );
    };
    it "on undef" => sub {
        is Email::RuleEngine::Base::get_header('Test-Undefined-Header'), undef;
    };
    it "on some data" => sub {
        is Email::RuleEngine::Base::get_header('Test-Header'), 1234567890;
    };
};

runtests unless caller;
