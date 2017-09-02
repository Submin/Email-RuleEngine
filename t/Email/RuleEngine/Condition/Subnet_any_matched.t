use Test::Spec;
use Test::Exception;

use Email::RuleEngine::Condition::Subnet;

my $text = 'From root@localhost Tue Dec 17 03:05:07 2013
Return-Path: <root@localhost>
Date: Tue, 17 Dec 2013 03:04:16 +0400 (MSK)
From: Charlie Root <root@localhost>
Message-Id: <201312162304.rBGN4GIO005229@localhost>
TestHeader11: 192.168.1.24
TestHeader13: {"Addr":["192.168.1.13","192.168.3.13"]}
TestHeader01: 192.168.3.24
TestHeader03: {"Addr":["192.168.3.13","192.168.4.13"]}
TestHeader2: ["192.168.1.0/24","192.168.2.0/24"]
To: root@localhost
Subject: localhost

Test';

my $cond;

describe "Email::RuleEngine::Condition::Subnet success on ANY Header with" => sub {
    before all => sub {
        $cond = Email::RuleEngine::Condition::Subnet->new;
        Email::RuleEngine::Base::set_object( $text );
    };
    it "single address value is match in conf subnets list" => sub {
        is $cond->run("in", ( 'Header/TestHeader11', 'Subnet/["192.168.1.0/24","192.168.2.0/24"]' )), 1;
    };
    it "single address value is not match in conf subnets list" => sub {
        is $cond->run("in", ( 'Header/TestHeader01', 'Subnet/["192.168.1.0/24","192.168.2.0/24"]' )), 0;
    };
    it "multigle addresses value as JSON string is match in conf subnets list" => sub {
        is $cond->run("in", ( 'Header/TestHeader13', 'Subnet/["192.168.1.0/24","192.168.2.0/24"]' )), 1;
    };
    it "multigle addresses value as JSON string is not match in conf subnets list" => sub {
        is $cond->run("in", ( 'Header/TestHeader03', 'Subnet/["192.168.1.0/24","192.168.2.0/24"]' )), 0;
    };
    it "single address value is match in header subnets list" => sub {
        is $cond->run("in", ( 'Header/TestHeader11', 'Header/TestHeader2' )), 1;
    };
    it "single address value is not match in header subnets list" => sub {
        is $cond->run("in", ( 'Header/TestHeader01', 'Header/TestHeader2' )), 0;
    };
    it "multigle addresses value as JSON string is match in header subnets list" => sub {
        is $cond->run("in", ( 'Header/TestHeader13', 'Header/TestHeader2' )), 1;
    };
    it "multigle addresses value as JSON string is not match in header subnets list" => sub {
        is $cond->run("in", ( 'Header/TestHeader03', 'Header/TestHeader2' )), 0;
    };
    it "single address value is match notin conf subnets list" => sub {
        is $cond->run("notin", ( 'Header/TestHeader11', 'Subnet/["192.168.1.0/24","192.168.2.0/24"]' )), 0;
    };
    it "single address value is not match notin conf subnets list" => sub {
        is $cond->run("notin", ( 'Header/TestHeader01', 'Subnet/["192.168.1.0/24","192.168.2.0/24"]' )), 1;
    };
    it "multigle addresses value as JSON string is match notin conf subnets list" => sub {
        is $cond->run("notin", ( 'Header/TestHeader13', 'Subnet/["192.168.1.0/24","192.168.2.0/24"]' )), 0;
    };
    it "multigle addresses value as JSON string is not match notin conf subnets list" => sub {
        is $cond->run("notin", ( 'Header/TestHeader03', 'Subnet/["192.168.1.0/24","192.168.2.0/24"]' )), 1;
    };
    it "single address value is match notin header subnets list" => sub {
        is $cond->run("notin", ( 'Header/TestHeader11', 'Header/TestHeader2' )), 0;
    };
    it "single address value is not match notin header subnets list" => sub {
        is $cond->run("notin", ( 'Header/TestHeader01', 'Header/TestHeader2' )), 1;
    };
    it "multigle addresses value as JSON string is match notin header subnets list" => sub {
        is $cond->run("notin", ( 'Header/TestHeader13', 'Header/TestHeader2' )), 0;
    };
    it "multigle addresses value as JSON string is not match notin header subnets list" => sub {
        is $cond->run("notin", ( 'Header/TestHeader03', 'Header/TestHeader2' )), 1;
    };
};

runtests unless caller;
