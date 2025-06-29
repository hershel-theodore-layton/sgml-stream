/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function as_arrays_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->test('test_the_arrays_are_unpacked_in_order', () ==> {
      $tag =
        <empty>
          {vec[1, vec[2, 3, dict['four' => 4, 'five' => keyset[5]]]]}
          {vec[vec[vec[6], 7], 8]}
        </empty>;
      expect(get_children($tag))->toEqual(vec[1, 2, 3, 4, 5, 6, 7, 8]);
    });
}
