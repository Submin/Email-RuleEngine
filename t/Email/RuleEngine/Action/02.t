use Test::Spec;
use Test::Exception;

use Email::RuleEngine::Base;
use Email::RuleEngine::Action::Dns;

my $test_header = 'TestHeader';
my $rule_ipv4 = {
    action => {
        options => {
            src_header => 'HeaderWithIPv4',
            dst_header => $test_header
        }
    }
};
my $rule_ipv6 = {
    action => {
        options => {
            src_header => 'HeaderWithIPv6',
            dst_header => $test_header
        }
    }
};
my $rule_domain = {
    action => {
        options => {
            src_header => 'HeaderWithDomain',
            dst_header => $test_header
        }
    }
};
my $rule_domains = {
    action => {
        options => {
            src_header => 'HeaderWithDomains',
            dst_header => $test_header
        }
    }
};

my $text = 'From root@localhost Tue Dec 17 03:05:07 2013
Return-Path: <root@localhost>
Date: Tue, 17 Dec 2013 03:04:16 +0400 (MSK)
From: Charlie Root <root@localhost>
Message-Id: <201312162304.rBGN4GIO005229@localhost>
To: root@localhost
HeaderWithIPv4: My IPv4 8.12.123.1 is a beautifull
HeaderWithIPv6: My IPv6 2001:db8::1:0:0:1 is a beautifull
HeaderWithDomain: My domain http://test1.ru have not problems
HeaderWithDomains: My domains http://test1.ru and https://test2.ru have not problems
Subject: My dear friend
Test';

my $action;

describe "Email::RuleEngine::Action::Dns" => sub {
    before all => sub {
        Email::RuleEngine::Base::set_object( $text );
        $action = Email::RuleEngine::Action::Dns->new;
        Net::DNS::Resolver->stubs(
            'new' => sub {
                bless {}, "Net::DNS::Resolver";
            },
            'search' => sub {
                my ( $self, $name, $type ) = @_;
                my $packet = stub(
                    answer => sub {
                        my @rr = @{shift->{answer}};
                    }
                );

                my $address = {
                    'test1.ru' => '10.0.0.1',
                    'test2.ru' => '2001:db8:0:0:0:0:2:1'
                }->{$name};

                if ( $type eq 'A' ) {
                    $packet->{answer} = [
                        stub( address => $address ),
                    ];
                }

                return bless $packet, 'Net::DNS::Packet';
            }
        );
    };

    it "fail on uncomplete rule" => sub {
        throws_ok sub { $action->run() }, qr/Options field is required/, "";
    };
    it "success on _domain" => sub {
        $action->run($rule_domain);
        is Email::RuleEngine::Base::get_header($test_header), '["10.0.0.1"]';
    };
};

runtests unless caller;
