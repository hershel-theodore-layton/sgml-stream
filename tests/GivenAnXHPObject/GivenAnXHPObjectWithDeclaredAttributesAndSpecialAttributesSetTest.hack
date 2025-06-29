/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function given_an_xhp_object_with_declared_attributes_and_special_attributes_set_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {

  $type_under_test_special_last = () ==>
    <herp_and_derp
      herp="h"
      derp={5.5}
      data-special="special"
      aria-role="test"
      data-more-special="more"
    />;

  $type_under_test_special_not_last = () ==>
    <herp_and_derp
      herp="h"
      data-special="special"
      aria-role="test"
      data-more-special="more"
      derp={5.5}
    />;

  $defaulted_derp = () ==>
    <herp_without_default_and_derp_defaulted herp="explicit" />;

  return $chain->group(__FUNCTION__)
    ->testAsync('test_renders_all_explicitly_set_attributes', async ()[
      defaults,
    ] ==> {
      $type_under_test = $type_under_test_special_last();
      expect(await $type_under_test->toHTMLStringAsync())->toEqual(
        '<herp_and_derp herp="h" derp="5.5" data-special="special" aria-role="test" data-more-special="more">'.
        '</herp_and_derp>',
      );
    })
    ->testAsync(
      'test_renders_attributes_in_order_of_xhp_open_tag_provided_no_value_is_defaulted_but_places_data_and_aria_last',
      async ()[defaults] ==> {
        $type_under_test = $type_under_test_special_not_last();
        expect(await $type_under_test->toHTMLStringAsync())->toEqual(
          '<herp_and_derp herp="h" derp="5.5" data-special="special" aria-role="test" data-more-special="more">'.
          '</herp_and_derp>',
        );
      },
    )
    ->testAsync(
      'test_renders_attributes_in_order_of_xhp_open_tag_but_default_values_which_are_not_set_go_first_',
      async ()[defaults] ==> {
        $type_under_test = $defaulted_derp();
        expect(await $type_under_test->toHTMLStringAsync())->toEqual(
          '<herp_without_default_and_derp_defaulted derp="default" herp="explicit">'.
          '</herp_without_default_and_derp_defaulted>',
        );
      },
    );
}
