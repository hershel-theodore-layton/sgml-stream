/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use function Facebook\FBExpect\expect;
use type Facebook\HackTest\HackTest;
use namespace HTL\SGMLStream;

final class rawtext extends SGMLStream\RootElement {
  protected string $tagName = 'rawtext';

  use SGMLStream\ElementWithOpenAndCloseTagsAndUnescapedContent;
}

final class BugsInElementWithOpenAndCloseTagsAndUnescapedContentTest
  extends HackTest {
  public function test_incomplete_closing_tags_in_content_throw(): void {
    $contains_closing_tag =
      'breaking out </rawtext <script>alert(document.domain);</script>';
    expect(
      () ==> (<rawtext>{$contains_closing_tag}</rawtext>)->toHTMLStringAsync(),
    )->toThrow(
      InvariantException::class,
      'that could be interpreted as a closing tag {</rawtext}',
    );
  }

  public function test_closing_tags_in_content_throw(): void {
    $contains_closing_tag =
      'breaking out </rawtext> <script>alert(document.domain);</script>';
    expect(
      () ==> (<rawtext>{$contains_closing_tag}</rawtext>)->toHTMLStringAsync(),
    )->toThrow(
      InvariantException::class,
      'that could be interpreted as a closing tag {</rawtext}',
    );
  }

  public function test_closing_tags_with_uppercase_letters_in_content_throw(
  ): void {
    $contains_closing_tag =
      'breaking out </RawText> <script>alert(document.domain);</script>';
    expect(
      () ==> (<rawtext>{$contains_closing_tag}</rawtext>)->toHTMLStringAsync(),
    )->toThrow(
      InvariantException::class,
      'that could be interpreted as a closing tag {</RawText}',
    );
  }
}
