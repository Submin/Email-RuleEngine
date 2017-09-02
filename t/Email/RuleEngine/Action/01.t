use Test::Spec;
use Test::Exception;

use Email::RuleEngine::Action::Factory;

my %PROVIDERS = %Email::RuleEngine::Action::Factory::ACTION_PROVIDERS;

describe "Email::RuleEngine::Action::Factory" => sub {
    describe "fail" => sub {
        it "on undefined type of condition" => sub {
            throws_ok sub { Email::RuleEngine::Action::Factory::create() },
                qr/Undefined action type/, "";
        };
        it "on unknown type of condition" => sub {
            throws_ok sub { Email::RuleEngine::Action::Factory::create('shikin@cpan.org') },
                qr/Unknown action type/, "";
        };
    };
    describe "success" => sub {
        foreach my $type ( keys %PROVIDERS ) {
            it " " => sub { require_ok $PROVIDERS{ $type }; };
            it "on get action ref of type '$type'" => sub {
                is ref Email::RuleEngine::Action::Factory::create($type), $PROVIDERS{ $type };
            }
        }
    };
};

runtests unless caller;
