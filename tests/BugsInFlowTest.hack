/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use function Facebook\FBExpect\expect;
use type HTL\SGMLStream\{ExclamationConstFlow, FirstComeFirstServedFlow};
use type HTL\SGMLStreamInterfaces\RedeclaredConstantException;

use type Facebook\HackTest\HackTest;

final class BugsInFlowTest extends HackTest {
  public function test_exclamation_const_flow_can_be_constructed_with_variables(
  ): void {
    $flow = ExclamationConstFlow::createWithConstantsAndVariables(
      dict['!const' => 'c'],
      dict['var' => 'v'],
    );
    expect($flow->getx('!const'))->toEqual('c');
    expect($flow->getx('var'))->toEqual('v');
  }

  public function test_first_come_first_served_flow_can_getx_a_null_constant(
  ): void {
    $flow = FirstComeFirstServedFlow::createWithConstantsAndVariables(
      dict['nullable' => null],
      dict[],
    );
    expect($flow->getx('nullable'))->toBeNull();
  }

  public function test_first_come_first_served_flow_does_not_permit_constant_overriding_in_the_constructor(
  ): void {
    expect(
      () ==> FirstComeFirstServedFlow::createWithConstantsAndVariables(
        dict['one' => true],
        dict['one' => false],
      ),
    )->toThrow(RedeclaredConstantException::class);
  }

  public function test_first_come_first_served_flow_declare_constant_exception_mentions_the_correct_storage_type(
  ): void {
    $flow = FirstComeFirstServedFlow::createWithConstantsAndVariables(
      dict['const' => true],
      dict['var' => false],
    );

    expect(() ==> $flow->declareConstant('const', false))->toThrow(
      RedeclaredConstantException::class,
      'constant with the name',
    );

    expect(() ==> $flow->declareConstant('var', false))->toThrow(
      RedeclaredConstantException::class,
      'variable with the name',
    );
  }
}
