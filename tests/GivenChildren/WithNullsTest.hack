/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function with_nulls_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->test('test_the_nulls_are_ignored', () ==> {
      $tag = <empty>{null}{1}{null}{1.1}{null}</empty>;
      expect(get_children($tag))->toEqual(vec[1, 1.1]);
    });
}
