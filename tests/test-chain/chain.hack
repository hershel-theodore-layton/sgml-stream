/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\Project_uN8Tv71L8o0F\GeneratedTestChain;

use namespace HTL\TestChain;

async function tests_async(
  TestChain\ChainController<\HTL\TestChain\Chain> $controller
)[defaults]: Awaitable<TestChain\ChainController<\HTL\TestChain\Chain>> {
  return $controller
    ->addTestGroup(\HTL\SGMLStream\Tests\as_arrays_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\as_elements_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\as_frags_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\as_numbers_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\as_strings_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\bugs_in_element_with_open_and_close_tags_and_unescaped_content_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\bugs_in_flow_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_a_spread_of_declared_defaulted_set_attribute_to_valid_target_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_a_spread_of_declared_defaulted_unset_attribute_to_valid_target_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_a_spread_of_declared_defaulted_unset_attribute_with_null_to_valid_target_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_a_spread_of_declared_set_attribute_to_a_tag_with_a_subset_of_the_declared_attributes_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_a_spread_of_declared_set_attribute_to_a_tag_with_identical_declared_attributes_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_a_spread_of_declared_set_attribute_to_a_tag_with_the_same_attribute_specified_as_null_in_the_xhp_open_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_a_spread_of_declared_set_attribute_to_a_tag_with_the_same_attribute_specified_in_the_xhp_open_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_a_spread_of_declared_set_attribute_to_a_tag_without_declared_attributes_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_a_spread_of_declared_set_attribute_with_null_to_valid_target_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_a_spread_of_special_attribute_to_a_tag_without_declared_attributes_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_a_spread_of_special_defaulted_set_attribute_to_valid_target_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_a_spread_of_special_defaulted_unset_attribute_to_valid_target_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_a_spread_of_special_set_attribute_to_a_tag_with_the_same_attribute_specified_in_the_xhp_open_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_a_spread_of_special_untyped_set_attribute_to_a_tag_with_the_same_attribute_but_with_a_type_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_an_xhp_object_with_a_boolean_attribute_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_an_xhp_object_with_declared_attributes_and_special_attributes_set_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_an_xhp_object_with_declared_attributes_not_set_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_an_xhp_object_with_declared_attributes_set_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_an_xhp_object_with_declared_defaulted_attributes_not_set_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_an_xhp_object_with_declared_defaulted_attributes_set_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_an_xhp_object_with_declared_late_init_attributes_not_set_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_an_xhp_object_with_declared_late_init_attributes_set_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_an_xhp_object_with_declared_required_attributes_set_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_an_xhp_object_with_special_attributes_set_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_an_xhp_object_with_special_defaulted_attributes_not_set_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_an_xhp_object_with_special_defaulted_attributes_set_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_an_xhp_object_with_special_required_attributes_set_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\given_an_xhp_object_without_attributes_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\legacy_user_elements_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\stringish_attribute_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\successor_flow_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\with_a_little_bit_of_everything<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\with_nulls_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\xhp_in_pure_context_test<>);
}
