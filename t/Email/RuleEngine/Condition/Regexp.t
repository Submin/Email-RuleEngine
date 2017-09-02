use Test::Spec;
use Test::Exception;

use Email::RuleEngine::Condition::Regexp;

my $text = 'From root@localhost Tue Dec 17 03:05:07 2013
Return-Path: <root@localhost>
Date: Tue, 17 Dec 2013 03:04:16 +0400 (MSK)
From: Charlie Root <root@localhost>
Message-Id: <201312162304.rBGN4GIO005229@localhost>
TestHeaderBool1: 0
TestHeaderBool2: 1
TestHeaderBool3:
To: root@localhost
Subject: localhost

Test';

my $cond;

describe "Email::RuleEngine::Condition::Regexp" => sub {
    before all => sub {
        $cond = Email::RuleEngine::Condition::Regexp->new;
        Email::RuleEngine::Base::set_object( $text );
    };
    it "fail on condition field 'op' has invalid value" => sub {
        is $cond->run("op", qw(1 2)), 0;
    };
    it "fail on limited size of expression 1" => sub {
        is $cond->run("=~", qw()), 0;
    };
    it "fail on limited size of expression 2" => sub {
        is $cond->run("!~", qw( 7 )), 0;
    };

    it "success on Header exist and match" => sub {
        is $cond->run("=~", qw( Header/TestHeaderBool1 Regexp/0 )), 1;
    };
    it "success on Header exist and unmatch" => sub {
        is $cond->run("!~", qw( Header/TestHeaderBool2 Regexp/0 )), 1;
    };
    it "success on Header exist but empty" => sub {
        is $cond->run("=~", qw( Header/TestHeaderBool3 Regexp/0 )), 0;
    };
    it "success on Header not exist" => sub {
        is $cond->run("=~", qw( Header/asd  Regexp/0 )), 0;
    };
    it "success on invalid label" => sub {
        is $cond->run("=~", qw( HeaderExist/TestHeaderBool1 Regexp/3 )), 0;
    };
};

runtests unless caller;
