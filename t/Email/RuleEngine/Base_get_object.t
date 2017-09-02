use Test::Spec;

use Email::RuleEngine::Base;

describe "Email::RuleEngine::Base get_object()" => sub {
    it "on success" => sub {
        my $data = 'test data';
        $Email::RuleEngine::Base::object = $data;
        is Email::RuleEngine::Base::get_object(), $data;
    };
};

runtests unless caller;
