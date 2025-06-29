/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function given_an_xhp_object_with_declared_defaulted_attributes_not_set_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  $type_under_test = () ==> <herp_defaulted />;

  return $chain->group(__FUNCTION__)
    ->test('test_access_yields_default_value', () ==> {
      $type_under_test = $type_under_test();
      expect($type_under_test->:herp)->toEqual('default');
    })
    ->testAsync(
      'test_renders_an_element_with_the_default_values',
      async ()[defaults] ==> {
        $type_under_test = $type_under_test();
        expect(await $type_under_test->toHTMLStringAsync())->toEqual(
          '<herp_defaulted herp="default"></herp_defaulted>',
        );
      },
    );
}
