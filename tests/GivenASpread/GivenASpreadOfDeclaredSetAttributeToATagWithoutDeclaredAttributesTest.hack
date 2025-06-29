/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function given_a_spread_of_declared_set_attribute_to_a_tag_without_declared_attributes_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->test('test_attributes_are_not_spread', () ==> {
      $type_under_test = <empty {...<herp_and_derp herp="h" derp={5.5} />} />;
      expect(get_attributes($type_under_test))->toEqual(tuple(dict[], dict[]));
    });
}
