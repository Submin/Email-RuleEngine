use Test::Spec;
use Email::Simple;

use Email::RuleEngine::Base;

my $text = 'From root@localhost Tue Dec 17 03:05:07 2013
Return-Path: <root@localhost>
From: Charlie Root <root@localhost>
To: root@localhost
Subject: localhost

Test';

describe "Email::RuleEngine::Base" => sub {
    describe "set_header()" => sub {
        it "on success" => sub {
            my $val = 9876543210;
            $Email::RuleEngine::Base::object = Email::Simple->new( $text );
            Email::RuleEngine::Base::set_header({'Test-Header' => $val});
            is $Email::RuleEngine::Base::object->header('Test-Header'), $val;
        };
    };
};

runtests unless caller;
