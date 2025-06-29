/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function given_a_spread_of_declared_set_attribute_to_a_tag_with_a_subset_of_the_declared_attributes_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->test('test_only_the_common_attributes_are_spread', () ==> {
      $type_under_test =
        <herp_and_derp {...<herp_and_durr herp="h" durr={5.5} />} />;
      expect(get_attributes($type_under_test))->toEqual(
        tuple(dict['herp' => 'h'], dict[]),
      );
    });
}
