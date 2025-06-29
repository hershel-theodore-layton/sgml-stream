/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function as_strings_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->test('test_the_strings_are_not_yet_escaped', () ==> {
      $tag = <empty>{'<script>'}</empty>;
      expect(get_children($tag))->toEqual(vec['<script>']);
    });
}
