/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function as_numbers_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->test('test_the_numbers_are_not_cast_to_a_string', () ==> {
      $tag = <empty>{1}{1.1}</empty>;
      expect(get_children($tag))->toEqual(vec[1, 1.1]);
    });
}
