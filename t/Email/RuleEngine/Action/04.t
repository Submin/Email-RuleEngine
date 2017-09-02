use Test::Spec;

use Email::RuleEngine::Base;
use Email::RuleEngine::Action::Mark;

my $text = 'From root@localhost Tue Dec 17 03:05:07 2013
Return-Path: <root@localhost>
Date: Tue, 17 Dec 2013 03:04:16 +0400 (MSK)
From: Charlie Root <root@localhost>
Message-Id: <201312162304.rBGN4GIO005229@localhost>
To: root@localhost
Subject: Test header http://test.ru

Test';

my $action;

describe "Email::RuleEngine::Action::Mark" => sub {
    before all => sub {
        $action = Email::RuleEngine::Action::Mark->new;
    };

    before each => sub {
        Email::RuleEngine::Base::set_object( $text );
    };

    it "absent header fields without options" => sub {
        $action->run({ action => {fields => {TestHeader => 1}} });
        is Email::RuleEngine::Base::get_header('TestHeader'), 1;
    };
    it "exist header fields without options" => sub {
        $action->run({ action => {fields => {Subject => 1}} });
        is Email::RuleEngine::Base::get_header('Subject'), 1;
    };
    it "absent header with options without fields" => sub {
        $action->run({ action => {options => {TestHeader => 'exact'}} });
        is Email::RuleEngine::Base::get_header('TestHeader'), undef;
    };
    it "exist header with options without fields" => sub {
        $action->run({ action => {options => {Subject => 'regexp'}} });
        is Email::RuleEngine::Base::get_header('Subject'), 'Test header http://test.ru';
    };

    it "header exist and not content" => sub {
        $action->run({
            action => {
                fields  => { Subject => '(test1\.ru)' },
                options => {
                    Subject => {
                        dst_header => 'SubjectContent',
                        type => 'regexp'
                    }
                }
            }
        });
        is Email::RuleEngine::Base::get_header('SubjectContent'), undef;
    };
    it "header exist and content" => sub {
        $action->run({
            action => {
                fields  => { Subject => '(test\.ru)' },
                options => {
                    Subject => {
                        dst_header => 'SubjectContent',
                        type => 'regexp'
                    }
                }
            }
        });
        is Email::RuleEngine::Base::get_header('SubjectContent'), 'test.ru';
    };
    it "copy unexist header" => sub {
        $action->run({
            action => {
                fields  => { TestHeader => '' },
                options => {
                    TestHeader => {
                        dst_header => 'NewTestHeader',
                        type => 'copy'
                    }
                }
            }
        });
        is Email::RuleEngine::Base::get_header('NewTestHeader'), undef;
    };
    it "copy exist header" => sub {
        $action->run({
            action => {
                fields  => { Subject => '' },
                options => {
                    Subject => {
                        dst_header => 'NewTestHeader',
                        type => 'copy'
                    }
                }
            }
        });
        is Email::RuleEngine::Base::get_header('NewTestHeader'),
            Email::RuleEngine::Base::get_header('Subject');
    };
};

runtests unless caller;
