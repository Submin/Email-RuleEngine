use Test::Spec;

use Email::RuleEngine::Base;
use Email::RuleEngine::Action::Kill;

my $test_header_value = 1234321;
my $rule = {
    action => {
        fields => {
            TestHeader => $test_header_value
        }
    }
};

my $text = 'From root@localhost Tue Dec 17 03:05:07 2013
Return-Path: <root@localhost>
Date: Tue, 17 Dec 2013 03:04:16 +0400 (MSK)
From: Charlie Root <root@localhost>
Message-Id: <201312162304.rBGN4GIO005229@localhost>
To: root@localhost
Subject: My domain http://test1.ru have not problems

Test';

my $action;
my $HEADER_PREFIX = 'X-OTRS-EmailFilter-Engine-';

describe "Email::RuleEngine::Action::Kill" => sub {
    before all => sub {
        Email::RuleEngine::Base::set_object( $text );
        $action = Email::RuleEngine::Action::Kill->new;
        $action->run($rule);
    };

    it "status" => sub {
        is Email::RuleEngine::Base::get_header($HEADER_PREFIX.'status'),
            'FINISHED';
    };
    it "message" => sub {
        is Email::RuleEngine::Base::get_header($HEADER_PREFIX.'message'),
            'Processing was killed directly';
    };
    it "additional header" => sub {
        is Email::RuleEngine::Base::get_header($HEADER_PREFIX.'TestHeader'),
            $test_header_value;
    };
};

runtests unless caller;
