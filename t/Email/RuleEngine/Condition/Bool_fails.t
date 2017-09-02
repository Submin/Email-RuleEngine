use Test::Spec;
use Test::Exception;

use Email::RuleEngine::Base;
use Email::RuleEngine::Condition::Bool;

my $text = 'From root@localhost Tue Dec 17 03:05:07 2013
Return-Path: <root@localhost>
Date: Tue, 17 Dec 2013 03:04:16 +0400 (MSK)
From: Charlie Root <root@localhost>
Message-Id: <201312162304.rBGN4GIO005229@localhost>
TestHeaderBool1: 0
TestHeaderBool2: 1
To: root@localhost
Subject: localhost

Test';

my $cond;

describe "Email::RuleEngine::Condition::Bool fail on" => sub {
    before all => sub {
        $cond = Email::RuleEngine::Condition::Bool->new;
        Email::RuleEngine::Base::set_object( $text );
    };
    it "condition field 'op' has invalid value" => sub {
        is $cond->run("op", qw(1)), 0;
    };
    it "limited size of expression" => sub {
        is $cond->run("&&", qw()), 0;
    };
    it "unknown labels" => sub {
        is $cond->run("&&", qw( HeaderAsd/TestHeaderBool1 )), 0;
    };
};

runtests unless caller;
