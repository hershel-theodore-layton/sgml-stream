/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function given_an_xhp_object_with_declared_attributes_not_set_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  $type_under_test = () ==> <herp_and_derp />;

  return $chain->group(__FUNCTION__)
    ->test('test_access_yields_null', () ==> {
      $type_under_test = $type_under_test();
      expect($type_under_test->:herp)->toBeNull();
      expect($type_under_test->:derp)->toBeNull();
    })
    ->testAsync('test_renders_an_empty_element', async ()[defaults] ==> {
      $type_under_test = $type_under_test();
      expect(await $type_under_test->toHTMLStringAsync())->toEqual(
        '<herp_and_derp></herp_and_derp>',
      );
    });
}
