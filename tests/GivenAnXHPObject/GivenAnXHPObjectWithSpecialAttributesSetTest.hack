/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\{expect, expect_invoked};

<<TestChain\Discover>>
function given_an_xhp_object_with_special_attributes_set_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  $type_under_test = () ==> <empty aria-special="as" data-special="ds" />;

  return $chain->group(__FUNCTION__)
    ->test('test_access_yields_value', () ==> {
      $type_under_test = $type_under_test();
      expect($type_under_test->:aria-special)->toEqual('as');
      expect($type_under_test->:data-special)->toEqual('ds');
    })
    ->test(
      'test_setting_a_non_arraykey_value_on_a_special_attribute_throws_',
      () ==> {
        expect_invoked(() ==> <empty data-special={1.1} />)->toHaveThrown<
          InvariantException,
        >();
      },
    )
    ->testAsync(
      'test_renders_all_explicitly_set_attributes',
      async ()[defaults] ==> {
        $type_under_test = $type_under_test();
        expect(await $type_under_test->toHTMLStringAsync())->toEqual(
          '<empty aria-special="as" data-special="ds">'.'</empty>',
        );
      },
    );
}
