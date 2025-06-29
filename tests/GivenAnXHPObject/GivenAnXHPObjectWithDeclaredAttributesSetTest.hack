/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function given_an_xhp_object_with_declared_attributes_set_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  $type_under_test = () ==> <herp_and_derp herp="h" derp={5.5} />;

  $type_under_test_inverse_attribute_order = () ==>
    <herp_and_derp derp={5.5} herp="h" />;

  return $chain->group(__FUNCTION__)
    ->test('test_access_yields_value', () ==> {
      $type_under_test = $type_under_test();
      expect($type_under_test->:herp)->toEqual('h');
      expect($type_under_test->:derp)->toEqual(5.5);
    })
    ->testAsync(
      'test_renders_all_explicitly_set_attributes',
      async ()[defaults] ==> {
        $type_under_test = $type_under_test();
        expect(await $type_under_test->toHTMLStringAsync())->toEqual(
          '<herp_and_derp herp="h" derp="5.5"></herp_and_derp>',
        );
      },
    )
    ->testAsync(
      'test_renders_all_explicitly_set_attributes_in_the_order_of_the_open_tag',
      async ()[defaults] ==> {
        $type_under_test = $type_under_test_inverse_attribute_order();
        expect(await $type_under_test->toHTMLStringAsync())->toEqual(
          '<herp_and_derp derp="5.5" herp="h"></herp_and_derp>',
        );
      },
    );
}
