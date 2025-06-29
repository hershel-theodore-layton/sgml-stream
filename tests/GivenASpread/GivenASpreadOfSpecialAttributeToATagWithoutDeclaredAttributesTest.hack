/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function given_a_spread_of_special_attribute_to_a_tag_without_declared_attributes_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->test('test_attributes_are_spread', () ==> {
      $type_under_test =
        <empty {...<empty data-special="special" aria-role="test" />} />;
      expect(get_attributes($type_under_test))->toEqual(
        tuple(dict[], dict['data-special' => 'special', 'aria-role' => 'test']),
      );
    });
}
