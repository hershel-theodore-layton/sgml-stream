/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\Project_uN8Tv71L8o0F\GeneratedTestChain;

use namespace HTL\TestChain;

async function tests_async(
  TestChain\ChainController<\HTL\TestChain\Chain> $controller
)[defaults]: Awaitable<TestChain\ChainController<\HTL\TestChain\Chain>> {
  return $controller
    ->addTestGroup(\HTL\SGMLStream\Tests\bugs_in_element_with_open_and_close_tags_and_unescaped_content_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\bugs_in_flow_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\legacy_user_elements_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\stringish_attribute_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\successor_flow_test<>)
    ->addTestGroup(\HTL\SGMLStream\Tests\xhp_in_pure_context_test<>);
}
