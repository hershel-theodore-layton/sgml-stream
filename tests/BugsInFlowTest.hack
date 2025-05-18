/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use type HTL\SGMLStream\{ExclamationConstFlow, FirstComeFirstServedFlow};
use type HTL\SGMLStreamInterfaces\RedeclaredConstantException;
use namespace HTL\TestChain;
use function HTL\Expect\{expect, expect_invoked};

<<TestChain\Discover>>
function bugs_in_flow_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->test(
      'test_exclamation_const_flow_can_be_constructed_with_variables',
      ()[defaults]: void ==> {
        $flow = ExclamationConstFlow::createWithConstantsAndVariables(
          dict['!const' => 'c'],
          dict['var' => 'v'],
        );
        expect($flow->getx('!const'))->toEqual('c');
        expect($flow->getx('var'))->toEqual('v');
      },
    )

    ->test(
      'test_first_come_first_served_flow_can_getx_a_null_constant',
      ()[defaults]: void ==> {
        $flow = FirstComeFirstServedFlow::createWithConstantsAndVariables(
          dict['nullable' => null],
          dict[],
        );
        expect($flow->getx('nullable'))->toBeNull();
      },
    )

    ->test(
      'test_first_come_first_served_flow_does_not_permit_constant_overriding_in_the_constructor',
      ()[defaults]: void ==> {
        expect_invoked(
          () ==> FirstComeFirstServedFlow::createWithConstantsAndVariables(
            dict['one' => true],
            dict['one' => false],
          ),
        )->toHaveThrown<RedeclaredConstantException>();
      },
    )

    ->test(
      'test_first_come_first_served_flow_declare_constant_exception_mentions_the_correct_storage_type',
      ()[defaults]: void ==> {
        $flow = FirstComeFirstServedFlow::createWithConstantsAndVariables(
          dict['const' => true],
          dict['var' => false],
        );

        expect_invoked(() ==> $flow->declareConstant('const', false))
          ->toHaveThrown<RedeclaredConstantException>('constant with the name');

        expect_invoked(() ==> $flow->declareConstant('var', false))
          ->toHaveThrown<RedeclaredConstantException>('variable with the name');
      },
    );
}
