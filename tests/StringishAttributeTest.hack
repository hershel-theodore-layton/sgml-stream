/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use function Facebook\FBExpect\expect;
use type Facebook\HackTest\HackTest;
use namespace HTL\SGMLStream;
use type Stringish;

final class StringishAttributeTest extends HackTest {
  public async function test_render_a_string_async(): Awaitable<void> {
    $lt = '<';
    expect(await (<StringishAttribute stringish={$lt} />)->toHTMLStringAsync())
      ->toEqual('<example stringish="&lt;">');
  }

  public async function test_render_a_stringish_object_async(
  ): Awaitable<void> {
    $lt = '<';
    expect(await (<StringishAttribute stringish={$lt} />)->toHTMLStringAsync())
      ->toEqual('<example stringish="&lt;">');
  }
}

final class StringishAttribute extends SGMLStream\RootElement {
  use SGMLStream\ElementWithOpenTagOnly;
  const ctx INITIALIZATION_CTX = [];
  const string TAG_NAME = 'example';

  attribute Stringish stringish @required;
}

final class StringishObject {
  public function __construct(private string $str)[] {}
  public function __toString(): string {
    return $this->str;
  }
}
