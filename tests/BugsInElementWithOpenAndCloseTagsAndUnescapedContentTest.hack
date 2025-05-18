/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\TestChain;
use function HTL\Expect\expect_invoked_async;

<<TestChain\Discover>>
function bugs_in_element_with_open_and_close_tags_and_unescaped_content_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testAsync(
      'test_incomplete_closing_tags_in_content_throw',
      async ()[defaults] ==> {
        $contains_closing_tag =
          'breaking out </rawtext <script>alert(document.domain);</script>';
        await expect_invoked_async(
          () ==>
            (<rawtext>{$contains_closing_tag}</rawtext>)->toHTMLStringAsync(),
        )
        |> $$->toHaveThrown<InvariantException>(
          'that could be interpreted as a closing tag {</rawtext}',
        );
      },
    )
    ->testAsync('test_closing_tags_in_content_throw', async ()[defaults] ==> {
      $contains_closing_tag =
        'breaking out </rawtext> <script>alert(document.domain);</script>';
      await expect_invoked_async(
        () ==>
          (<rawtext>{$contains_closing_tag}</rawtext>)->toHTMLStringAsync(),
      )
      |> $$->toHaveThrown<InvariantException>(
        'that could be interpreted as a closing tag {</rawtext}',
      );
    })
    ->testAsync(
      'test_closing_tags_with_uppercase_letters_in_content_throw',
      async ()[defaults] ==> {
        $contains_closing_tag =
          'breaking out </RawText> <script>alert(document.domain);</script>';
        await expect_invoked_async(
          () ==>
            (<rawtext>{$contains_closing_tag}</rawtext>)->toHTMLStringAsync(),
        )
        |> $$->toHaveThrown<InvariantException>(
          'that could be interpreted as a closing tag {</RawText}',
        );
      },
    );
}
