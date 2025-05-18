/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\{SGMLStream, TestChain};
use function HTL\Expect\expect;
use type Stringish;

<<TestChain\Discover>>
function stringish_attribute_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testAsync(
      'test_render_a_string_async',
      async ()[defaults] ==> {
        $lt = '<';
        expect(
          await (<StringishAttribute stringish={$lt} />)->toHTMLStringAsync(),
        )
          ->toEqual('<example stringish="&lt;">');
      },
    )
    ->testAsync(
      'test_render_a_stringish_object_async',
      async ()[defaults] ==> {
        $lt = '<';
        expect(
          await (<StringishAttribute stringish={$lt} />)->toHTMLStringAsync(),
        )
          ->toEqual('<example stringish="&lt;">');
      },
    );
}

final class StringishAttribute extends SGMLStream\RootElement {
  use SGMLStream\ElementWithOpenTagOnly;
  const ctx INITIALIZATION_CTX = [];
  const string TAG_NAME = 'example';

  attribute Stringish stringish @required;
}

final class StringishObject {
  public function __construct(private string $str)[] {}
  public function __toString()[]: string {
    return $this->str;
  }
}
