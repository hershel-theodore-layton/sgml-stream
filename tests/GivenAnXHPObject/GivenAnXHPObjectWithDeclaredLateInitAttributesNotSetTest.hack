/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function given_an_xhp_object_with_declared_late_init_attributes_not_set_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  $type_under_test = () ==> <herp_lateinit />;
  return $chain->group(__FUNCTION__)
    ->test('test_access_yields_null_', () ==> {
      $type_under_test = $type_under_test();
      expect($type_under_test->:herp)->toBeNull();
      // 'This is actually pretty bad, since this is not type safe. '.
      // 'sgml-stream does not expose a way to set attributes after construction either. '.
      // 'So lateinit could never be valid.',
    })
    ->testAsync('test_renders_an_empty_element', async ()[defaults] ==> {
      $type_under_test = $type_under_test();
      expect(await $type_under_test->toHTMLStringAsync())->toEqual(
        '<herp_lateinit></herp_lateinit>',
      );
    });
}
