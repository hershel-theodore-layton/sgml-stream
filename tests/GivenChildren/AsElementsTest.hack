/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function as_elements_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->test('test_the_elements_are_saved', () ==> {
      $child_1 = <empty />;
      $child_2 = <herp_and_durr />;
      $tag = <empty>{$child_1}{$child_2}</empty>;
      expect(get_children($tag))->toEqual(vec[$child_1, $child_2]);
    });
}
