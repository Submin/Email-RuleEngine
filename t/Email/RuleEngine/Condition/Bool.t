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

describe "Email::RuleEngine::Condition::Bool success on" => sub {
    before all => sub {
        $cond = Email::RuleEngine::Condition::Bool->new;
        Email::RuleEngine::Base::set_object( $text );
    };
    it "HeaderExist single 1" => sub {
        is $cond->run("||", qw( HeaderExist/TestHeaderBool1 )), 1;
    };
    it "HeaderExist single 2" => sub {
        is $cond->run("!", qw( HeaderExist/asd )), 1;
    };
    it "HeaderExist multiple 1" => sub {
        is $cond->run("&&", qw( HeaderExist/TestHeaderBool1 HeaderExist/TestHeaderBool2 )), 1;
    };
    it "HeaderExist multiple 2" => sub {
        is $cond->run("&&", qw( HeaderExist/TestHeaderBool2 HeaderExist/rtujety )), 0;
    };
    it "HeaderAbsent single 1" => sub {
        is $cond->run("&&", qw( HeaderAbsent/asd )), 1;
    };
    it "HeaderAbsent single 2" => sub {
        is $cond->run("&&", qw( HeaderAbsent/TestHeaderBool1 )), 0;
    };
    it "HeaderAbsent multiple 1" => sub {
        is $cond->run("&&", qw( HeaderAbsent/asd HeaderAbsent/dsa )), 1;
    };
    it "HeaderAbsent multiple 2" => sub {
        is $cond->run("&&", qw( HeaderAbsent/asd HeaderAbsent/TestHeaderBool2 )), 0;
    };
    it "HeaderAbsent multiple 3" => sub {
        is $cond->run("||", qw( HeaderAbsent/asd HeaderAbsent/TestHeaderBool2 )), 1;
    };
    it "HeaderTrue single 1" => sub {
        is $cond->run("&&", qw( HeaderTrue/TestHeaderBool1 )), 0;
    };
    it "HeaderTrue single 2" => sub {
        is $cond->run("&&", qw( HeaderTrue/TestHeaderBool2 )), 1;
    };
    it "HeaderTrue multiple 1" => sub {
        is $cond->run("&&", qw( HeaderTrue/TestHeaderBool1 HeaderTrue/TestHeaderBool2 )), 0;
    };
    it "HeaderTrue multiple 2" => sub {
        is $cond->run("||", qw( HeaderTrue/TestHeaderBool1 HeaderTrue/TestHeaderBool2 )), 1;
    };
    it "HeaderFalse single 1" => sub {
        is $cond->run("&&", qw( HeaderFalse/TestHeaderBool1 )), 1;
    };
    it "HeaderFalse single 2" => sub {
        is $cond->run("&&", qw( HeaderFalse/TestHeaderBool2 )), 0;
    };
    it "HeaderFalse multiple 1" => sub {
        is $cond->run("&&", qw( HeaderFalse/TestHeaderBool1 HeaderFalse/TestHeaderBool2 )), 0;
    };
    it "HeaderFalse multiple 2" => sub {
        is $cond->run("||", qw( HeaderFalse/TestHeaderBool1 HeaderFalse/TestHeaderBool2 )), 1;
    };
};

runtests unless caller;
