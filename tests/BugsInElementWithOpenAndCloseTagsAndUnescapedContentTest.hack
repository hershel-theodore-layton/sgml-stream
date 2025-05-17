/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use type Facebook\HackTest\HackTest;
use function HTL\Expect\expect_invoked_async;

final class BugsInElementWithOpenAndCloseTagsAndUnescapedContentTest
  extends HackTest {
  public async function test_incomplete_closing_tags_in_content_throw(
  )[defaults]: Awaitable<void> {
    $contains_closing_tag =
      'breaking out </rawtext <script>alert(document.domain);</script>';
    await expect_invoked_async(
      () ==> (<rawtext>{$contains_closing_tag}</rawtext>)->toHTMLStringAsync(),
    )
      |> $$->toHaveThrown<InvariantException>(
        'that could be interpreted as a closing tag {</rawtext}',
      );
  }

  public async function test_closing_tags_in_content_throw(
  )[defaults]: Awaitable<void> {
    $contains_closing_tag =
      'breaking out </rawtext> <script>alert(document.domain);</script>';
    await expect_invoked_async(
      () ==> (<rawtext>{$contains_closing_tag}</rawtext>)->toHTMLStringAsync(),
    )
      |> $$->toHaveThrown<InvariantException>(
        'that could be interpreted as a closing tag {</rawtext}',
      );
  }

  public async function test_closing_tags_with_uppercase_letters_in_content_throw(
  )[defaults]: Awaitable<void> {
    $contains_closing_tag =
      'breaking out </RawText> <script>alert(document.domain);</script>';
    await expect_invoked_async(
      () ==> (<rawtext>{$contains_closing_tag}</rawtext>)->toHTMLStringAsync(),
    )
      |> $$->toHaveThrown<InvariantException>(
        'that could be interpreted as a closing tag {</RawText}',
      );
  }
}
