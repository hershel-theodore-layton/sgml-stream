/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function with_a_little_bit_of_everything(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->test('test_the_frags_and_arrays_are_unpacked_in_order', () ==> {
      $tag =
        <empty>
          {frag(vec[1, 2, frag(keyset[3, 4, 5]), 6, null])}
          Some text here
          {frag(null)}
          {null}
          With lots of &hearts;
        </empty>;
      expect(get_children($tag))->toEqual(
        vec[1, 2, 3, 4, 5, 6, ' Some text here ', ' With lots of ♥ '],
      );
    });
}
