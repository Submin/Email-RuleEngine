use Test::Spec;

use Email::RuleEngine::Base;

describe "Email::RuleEngine::Base traverse_expr_check()" => sub {
    it "fail on condition undefined" => sub {
        like Email::RuleEngine::Base::traverse_expr_check(),
            qr/Expression is undefined/;
    };
    it "fail on invalid condition format" => sub {
        like Email::RuleEngine::Base::traverse_expr_check(1,2),
            qr/Expression must be a hash ref/;
    };
    it "fail without some condition fields" => sub {
        like Email::RuleEngine::Base::traverse_expr_check( { type => 1, op => 2 } ),
            qr/Required expression field \'\w+?\' is absent/;
    };
    it "fail on condition field 'expression' must be array ref" => sub {
        like Email::RuleEngine::Base::traverse_expr_check({
            type => 1, op => 2, expression => 3
        }), qr/Condition field \'expression\' must be array ref/;
    };
    it "fail on condition field 'expression' must from consist one or more items" => sub {
        like Email::RuleEngine::Base::traverse_expr_check({
            type => 1, op => 2, expression => []
        }), qr/Condition field \'expression\' must from consist one or more items/;
    };
    it "on success" => sub {
        is Email::RuleEngine::Base::traverse_expr_check({
            type => 'bool', op => '&&', expression => [1, {type => 'char', op => 'eq', expression => ['asd', 'dsa']}]
        }), undef;
    };
};

runtests unless caller;
