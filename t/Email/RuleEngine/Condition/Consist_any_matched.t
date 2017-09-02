use Test::Spec;
use Test::Exception;

use Email::RuleEngine::Condition::Consist;

my $text = 'From root@localhost Tue Dec 17 03:05:07 2013
Return-Path: <root@localhost>
Date: Tue, 17 Dec 2013 03:04:16 +0400 (MSK)
From: Charlie Root <root@localhost>
Message-Id: <201312162304.rBGN4GIO005229@localhost>
TestHeader1: test123
TestHeader2: {"Sublist":["test123","abyrvalg"]}
TestHeader3: {"Sublist":["test12","abyrvalg"]}
TestHeader4: {"List":["0","test123","prim"]}
TestHeader5: {"List":["0","test12","prim"]}
To: root@localhost
Subject: localhost

Test';

my $cond;

describe "Email::RuleEngine::Condition::Consist success on ANY Header with" => sub {
    before all => sub {
        $cond = Email::RuleEngine::Condition::Consist->new;
        Email::RuleEngine::Base::set_object( $text );
    };
    it "single value is in conf list" => sub {
        is $cond->run("in", ( 'Header/TestHeader1', 'List/["0","test123","prim"]' )), 1;
    };
    it "single value isn't in conf list" => sub {
        is $cond->run("in", ( 'Header/TestHeader1', 'List/["0","test12","prim"]' )), 0;
    };
    it "single value is notin conf list 1" => sub {
        is $cond->run("notin", ( 'Header/TestHeader1', 'List/["0","test123","prim"]' )), 0;
    };
    it "single value is notin conf list 2" => sub {
        is $cond->run("notin", ( 'Header/TestHeader1', 'List/["0","test12","prim"]' )), 1;
    };
    it "multiple value intersect of conf list" => sub {
        is $cond->run("in", ( 'Header/TestHeader2', 'List/["0","test123","prim"]' )), 1;
    };
    it "multiple value isn't intersect of conf list" => sub {
        is $cond->run("in", ( 'Header/TestHeader3', 'List/["0","test123","prim"]' )), 0;
    };
    it "multiple value notintersect of conf list 1" => sub {
        is $cond->run("notin", ( 'Header/TestHeader3', 'List/["0","test123","prim"]' )), 1;
    };
    it "multiple value notintersect of conf list 2" => sub {
        is $cond->run("notin", ( 'Header/TestHeader2', 'List/["0","test123","prim"]' )), 0;
    };
    it "single value is in hand list" => sub {
        is $cond->run("in", ( 'Header/TestHeader1', 'Header/TestHeader4' )), 1;
    };
    it "single value isn't in hand list" => sub {
        is $cond->run("in", ( 'Header/TestHeader1', 'Header/TestHeader5' )), 0;
    };
    it "single value is notin hand list 1" => sub {
        is $cond->run("notin", ( 'Header/TestHeader1', 'Header/TestHeader4' )), 0;
    };
    it "single value is notin hand list 2" => sub {
        is $cond->run("notin", ( 'Header/TestHeader1', 'Header/TestHeader5' )), 1;
    };
    it "multiple value intersect of hand list" => sub {
        is $cond->run("in", ( 'Header/TestHeader2', 'Header/TestHeader4' )), 1;
    };
    it "multiple value isn't intersect of hand list" => sub {
        is $cond->run("in", ( 'Header/TestHeader3', 'Header/TestHeader4' )), 0;
    };
    it "multiple value notintersect of hand list 1" => sub {
        is $cond->run("notin", ( 'Header/TestHeader3', 'Header/TestHeader4' )), 1;
    };
    it "multiple value notintersect of hand list 2" => sub {
        is $cond->run("notin", ( 'Header/TestHeader2', 'Header/TestHeader4' )), 0;
    };
};

runtests unless caller;
