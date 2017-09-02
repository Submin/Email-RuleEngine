use Test::Spec;

use Email::RuleEngine;
use Email::RuleEngine::Action;
use Email::RuleEngine::Base;
use Email::RuleEngine::Condition;
use Email::RuleEngine::Condition::Factory;
use Email::RuleEngine::Condition::Bool;
use Email::RuleEngine::Condition::Cmp;
use Email::RuleEngine::Condition::Consist;
use Email::RuleEngine::Condition::Subnet;
use Email::RuleEngine::Condition::Regexp;
use Email::RuleEngine::Action::Factory;
use Email::RuleEngine::Action::Extract;
use Email::RuleEngine::Action::Goto;
use Email::RuleEngine::Action::Kill;
use Email::RuleEngine::Action::Mark;
use Email::RuleEngine::Action::Resolve;

my @engine_can_methods = qw(
    run
    _loop
    traverse_build
    action
    inc_recursion
    set_object
    get_object
    set_node
    get_node
    check
);

my @engine_base_can_methods = qw(
    internal_header_set
    inc_recursion
    update_chain
    set_object
    get_object
    set_header
    get_header
    get_body
    set_node
    get_node
    check
    croak
    clone
    encode_json
    decode_json
);

my @engine_condition_can_methods = qw(
    traverse_build
    build
);
my @engine_action_can_methods = qw(
    update_chain
    internal_header_set
    action
);

my @engine_factory_can_methods = qw(
    create
    croak
    load_class
);

my @engine_base_methods = ( 'new', 'run' );

my @engine_conditions_can_methods = (
    @engine_base_methods,
    'update_chain',
    'get_header',
    'croak',
    'any'
);

describe " " => sub {
    it "Email::RuleEngine" => sub {
        can_ok('Email::RuleEngine',
            @engine_can_methods);
    };
    it "Email::RuleEngine::Base" => sub {
        can_ok('Email::RuleEngine::Base',
            @engine_base_can_methods);
    };
    it "Email::RuleEngine::Condition" => sub {
        can_ok('Email::RuleEngine::Condition',
            @engine_condition_can_methods);
    };
    it "Email::RuleEngine::Condition::Factory" => sub {
        can_ok('Email::RuleEngine::Condition::Factory',
            @engine_factory_can_methods);
    };
    it "Email::RuleEngine::Condition::Bool" => sub {
        can_ok('Email::RuleEngine::Condition::Bool',
            @engine_conditions_can_methods);
    };
    it "Email::RuleEngine::Condition::Cmp" => sub {
        can_ok('Email::RuleEngine::Condition::Cmp',
            @engine_conditions_can_methods);
    };
    it "Email::RuleEngine::Condition::Consist" => sub {
        can_ok('Email::RuleEngine::Condition::Consist',
            (@engine_conditions_can_methods, 'decode_json'));
    };
    it "Email::RuleEngine::Condition::Subnet" => sub {
        can_ok('Email::RuleEngine::Condition::Subnet',
            (@engine_conditions_can_methods, 'subnet_matcher', 'decode_json'));
    };
    it "Email::RuleEngine::Condition::Regexp" => sub {
        can_ok('Email::RuleEngine::Condition::Regexp',
            @engine_conditions_can_methods);
    };
    it "Email::RuleEngine::Action" => sub {
        can_ok('Email::RuleEngine::Action',
            @engine_action_can_methods);
    };
    it "Email::RuleEngine::Action::Factory" => sub {
        can_ok('Email::RuleEngine::Action::Factory',
            @engine_factory_can_methods);
    };
    it "Email::RuleEngine::Action::Extract" => sub {
        can_ok('Email::RuleEngine::Action::Extract',
            (@engine_base_methods, 'set_header', 'get_header', 'encode_json'));
    };
    it "Email::RuleEngine::Action::Goto" => sub {
        can_ok('Email::RuleEngine::Action::Goto',
            @engine_base_methods);
    };
    it "Email::RuleEngine::Action::Kill" => sub {
        can_ok('Email::RuleEngine::Action::Kill',
            (@engine_base_methods, 'internal_header_set'));
    };
    it "Email::RuleEngine::Action::Mark" => sub {
        can_ok('Email::RuleEngine::Action::Mark',
            (@engine_base_methods, 'set_header'));
    };
    it "Email::RuleEngine::Action::Resolve" => sub {
        can_ok('Email::RuleEngine::Action::Resolve',
            (@engine_base_methods, 'is_domain', 'domain_to_ascii', 'encode_json', 'set_header', 'get_header'));
    };

};

runtests unless caller;
