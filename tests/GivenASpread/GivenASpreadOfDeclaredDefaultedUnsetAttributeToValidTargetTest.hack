/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function given_a_spread_of_declared_defaulted_unset_attribute_to_valid_target_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->test('test_the_default_value_is_spread', () ==> {
      $type_under_test = <herp_and_derp {...<herp_defaulted />} />;
      expect(get_attributes($type_under_test))->toEqual(
        tuple(dict['herp' => 'default'], dict[]),
      );
    });
}
