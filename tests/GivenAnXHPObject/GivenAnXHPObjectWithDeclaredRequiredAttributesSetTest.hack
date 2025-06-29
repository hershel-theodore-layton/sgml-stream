/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function given_an_xhp_object_with_declared_required_attributes_set_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  $type_under_test = () ==> <herp_required herp="required" />;

  return $chain->group(__FUNCTION__)
    ->test('test_access_yields_value', () ==> {
      $type_under_test = $type_under_test();
      expect($type_under_test->:herp)->toEqual('required');
    })
    ->testAsync(
      'test_renders_all_explicitly_set_attributes',
      async ()[defaults] ==> {
        $type_under_test = $type_under_test();
        expect(await $type_under_test->toHTMLStringAsync())->toEqual(
          '<herp_required herp="required"></herp_required>',
        );
      },
    );
}
