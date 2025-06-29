/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function given_an_xhp_object_with_special_defaulted_attributes_set_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  $type_under_test = () ==>
    <data_special_defaulted data-special="not-default" />;

  return $chain->group(__FUNCTION__)
    ->test('test_access_yields_explicitly_set_value', () ==> {
      $type_under_test = $type_under_test();
      expect($type_under_test->:data-special)->toEqual('not-default');
    })
    ->testAsync(
      'test_renders_all_explicitly_set_attributes',
      async ()[defaults] ==> {
        $type_under_test = $type_under_test();
        expect(await $type_under_test->toHTMLStringAsync())->toEqual(
          '<data_special_defaulted data-special="not-default">'.
          '</data_special_defaulted>',
        );
      },
    );
}
