/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function as_frags_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->test('test_the_frags_are_unpacked_in_order', () ==> {
      $tag =
        <empty>
          {frag(vec[1, 2, frag(keyset[3, 4, 5]), 6])}
          {frag(7)}
        </empty>;
      expect(get_children($tag))->toEqual(vec[1, 2, 3, 4, 5, 6, 7]);
    });
}
