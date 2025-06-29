/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function given_a_spread_of_declared_defaulted_unset_attribute_with_null_to_valid_target_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->test(
      'test_the_null_value_is_not_copied_in_the_spread',
      () ==> {
        $type_under_test =
          <herp_and_derp herp="not-null" {...<herp_defaulted_with_null />} />;
        expect(get_attributes($type_under_test))->toEqual(
          tuple(dict['herp' => 'not-null'], dict[]),
        );
      },
    );
}
