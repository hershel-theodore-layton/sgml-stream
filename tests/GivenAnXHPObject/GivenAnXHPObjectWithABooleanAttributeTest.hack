/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function given_an_xhp_object_with_a_boolean_attribute_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  $type_under_test_true = () ==> <bull burp={true} />;
  $type_under_test_false = () ==> <bull burp={false} />;

  return $chain->group(__FUNCTION__)
    ->test('test_access_yields_null', () ==> {
      $type_under_test = $type_under_test_true();
      expect($type_under_test->:burp)->toBeTrue();
      $type_under_test = $type_under_test_false();
      expect($type_under_test->:burp)->toBeFalse();
    })
    ->testAsync(
      'test_renders_true_as_a_valueless_attribute',
      async ()[defaults] ==> {
        $type_under_test = $type_under_test_true();
        expect(await $type_under_test->toHTMLStringAsync())->toEqual(
          '<bull burp></bull>',
        );
      },
    )
    ->testAsync(
      'test_renders_false_as_an_attribute_with_the_value_of_an_empty_string',
      async ()[defaults] ==> {
        $type_under_test = $type_under_test_false();
        expect(await $type_under_test->toHTMLStringAsync())->toEqual(
          '<bull burp=""></bull>',
        );
      },
    );
}
