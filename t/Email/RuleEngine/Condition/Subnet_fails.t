use Test::Spec;
use Test::Exception;

use Email::RuleEngine::Condition::Subnet;

my $text = 'From root@localhost Tue Dec 17 03:05:07 2013
Return-Path: <root@localhost>
Date: Tue, 17 Dec 2013 03:04:16 +0400 (MSK)
From: Charlie Root <root@localhost>
Message-Id: <201312162304.rBGN4GIO005229@localhost>
TestHeader1: test123
TestHeader2: {"Sublist":["test321","abyrvalg"]}
TestHeader3: {"Sublist":["test32","abyrvalg"]}
To: root@localhost
Subject: localhost

Test';

my $cond;

describe "Email::RuleEngine::Condition::Subnet fail on" => sub {
    before all => sub {
        $cond = Email::RuleEngine::Condition::Subnet->new;
        Email::RuleEngine::Base::set_object( $text );
    };
    it "condition field 'op' has invalid value" => sub {
        is $cond->run("op", qw(1 2)), 0;
    };
    it "limited size of expression 1" => sub {
        is $cond->run("in", qw()), 0;
    };
    it "limited size of expression 2" => sub {
        is $cond->run("in", qw( 7 )), 0;
    };
};

runtests unless caller;
