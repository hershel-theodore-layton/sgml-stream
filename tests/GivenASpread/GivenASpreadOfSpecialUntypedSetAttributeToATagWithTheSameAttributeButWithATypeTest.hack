/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function given_a_spread_of_special_untyped_set_attribute_to_a_tag_with_the_same_attribute_but_with_a_type_test(
  TestChain\Chain $chain,
)[leak_safe]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->test(
      'test_the_explicitly_set_value_is_spread_even_though_this_might_set_a_value_of_a_different_type',
      () ==> {
        $type_under_test =
          <data_special_typed {...<empty data-special={42} />} />;
        expect(get_attributes($type_under_test))->toEqual(
          tuple(dict[], dict['data-special' => 42]),
        );

        $error_level = \error_reporting(0);
        try {
          // Passing an int to a function which expects a ?string.
          // Both sgml-stream and xhp-lib fail to ensure type safety here.
          takes_nullable_string($type_under_test->:data-special);
        } finally {
          \error_reporting($error_level);
        }
      },
    );
}

function takes_nullable_string(<<__Soft>> ?string $string_or_null)[]: void {
  expect($string_or_null)->toHaveType<int>();
}
