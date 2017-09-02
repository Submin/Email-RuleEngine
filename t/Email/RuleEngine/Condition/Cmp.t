use Test::Spec;
use Data::Dumper;
use Email::RuleEngine::Condition::Cmp;

my $text = 'From root@localhost Tue Dec 17 03:05:07 2013
Return-Path: <root@localhost>
Date: Tue, 17 Dec 2013 03:04:16 +0400 (MSK)
From: Charlie Root <root@localhost>
Message-Id: <201312162304.rBGN4GIO005229@localhost>
TestHeaderBool1: 0
TestHeaderBool2: 1
TestHeaderBool3: 00
TestHeaderBool3:
To: root@localhost
Subject: localhost

Test';

my $cond;

describe "Email::RuleEngine::Condition::Cmp" => sub {
    before all => sub {
        Email::RuleEngine::Condition::Cmp->stubs('update_chain' => {});
        $cond = Email::RuleEngine::Condition::Cmp->new;
        Email::RuleEngine::Base::set_object( $text );
    };
    it "fail on absent operator" => sub {
        is $cond->run(), 0;
    };
    it "fail on condition field 'op' has invalid value" => sub {
        is $cond->run("op", qw()), 0;
    };
    it "fail on limited size of expression 1" => sub {
        is $cond->run("==", qw()), 0;
    };
    it "fail on limited size of expression 2" => sub {
        is $cond->run("eq", qw( asd )), 0;
    };

    it "success on Header exist and equal" => sub {
        is $cond->run("eq", qw( Header/TestHeaderBool1 Value/0 )), 1;
    };
    it "success on Header exist and not equal" => sub {
        is $cond->run("eq", qw( Header/TestHeaderBool1 Value/asd )), 0;
    };
    it "success on Header exist but empty" => sub {
        is $cond->run("eq", qw( Header/TestHeaderBool3 Value/asd )), 0;
    };
    it "success on Header not exist" => sub {
        is $cond->run("ne", qw( Header/asd  Value/asd )), 0;
    };
    it "success on invalid label" => sub {
        is $cond->run("gt", qw( HeaderExist/TestHeaderBool1 Value/Test )), 0;
    };
    it "success on number comparision" => sub {
        is $cond->run("==", qw( Header/TestHeaderBool1 Header/TestHeaderBool3 )), 1;
    };
    it "success on string comparision" => sub {
        is $cond->run("eq", qw( Header/TestHeaderBool1 Header/TestHeaderBool3 )), 0;
    };
};

runtests unless caller;
