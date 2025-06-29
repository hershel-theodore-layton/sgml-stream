/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function given_a_spread_of_declared_defaulted_set_attribute_to_valid_target_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->test('test_the_explicitly_set_value_is_spread', () ==> {
      $type_under_test =
        <herp_and_derp {...<herp_defaulted herp="not-default" />} />;
      expect(get_attributes($type_under_test))->toEqual(
        tuple(dict['herp' => 'not-default'], dict[]),
      );
    });
}
