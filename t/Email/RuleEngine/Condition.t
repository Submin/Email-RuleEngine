use Test::Spec;
use Clone qw( clone );

use Email::RuleEngine::Condition;

describe "Email::RuleEngine::Condition" => sub {
    describe "traverse_build()" => sub {
        before all => sub {
            Email::RuleEngine::Condition->stubs( 'build' => sub {
                my ( $tail, @expr ) = @_;
                return join ' ', @expr;
            });
        };
        it "on single iteration" => sub {
            is Email::RuleEngine::Condition::traverse_build({expression => ['asd', 54]}), "asd 54";
        };
        it "on multiple iteration" => sub {
            my $expression = {
                expression => [
                    'qwerty',
                    {
                        expression => [
                            54,
                            {
                                expression => [
                                    'asd',
                                    'dsa'
                                ]
                            }
                        ]
                    }
                ]
            };
            is Email::RuleEngine::Condition::traverse_build( $expression ),
                "qwerty 54 asd dsa";
        };
    };
};

runtests unless caller;
