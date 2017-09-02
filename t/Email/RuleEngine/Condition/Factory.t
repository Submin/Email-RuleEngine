use Test::Spec;
use Test::Exception;

use Email::RuleEngine::Condition::Factory;

my %PROVIDERS = %Email::RuleEngine::Condition::Factory::CONDITION_PROVIDERS;

describe "Email::RuleEngine::Condition::Factory" => sub {
    describe "fail" => sub {
        it "on undefined type of condition" => sub {
            throws_ok sub { Email::RuleEngine::Condition::Factory::create() },
                qr/Undefined condition type/, "";
        };
        it "on unknown type of condition" => sub {
            throws_ok sub { Email::RuleEngine::Condition::Factory::create('shikin@cpan.org') },
                qr/Unknown condition type/, "";
        };
    };
    describe "success" => sub {
        foreach my $type ( keys %PROVIDERS ) {
            it " " => sub { require_ok $PROVIDERS{ $type }; };
            it "on get condition ref of type '$type'" => sub {
                is ref Email::RuleEngine::Condition::Factory::create($type), $PROVIDERS{ $type };
            }
        }
    };
};

runtests unless caller;
