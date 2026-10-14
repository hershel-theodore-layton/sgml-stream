/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\{SGMLStream, TestChain};
use function HTL\Expect\expect;
use function bin2hex;

<<TestChain\Discover>>
function utf8_escaping_test(TestChain\Chain $chain)[]: TestChain\Chain {
  $chain = $chain->group(__FUNCTION__);
  foreach (
    dict[
      "before\xffafter" => 'before�after',
      "before\x80after" => 'before�after',
      "before\xe2\x82" => 'before�',
      'café 😀' => 'café 😀',
      '<>&"\'' => '&lt;&gt;&amp;&quot;\'',
      "<\xff&\"after" => '&lt;�&amp;&quot;after',
    ] as $input => $escaped
  ) {
    $chain = $chain->testAsync(
      'escape_'.bin2hex($input),
      async ()[defaults] ==> {
        $element = new UTF8Element(
          dict[
            'title' => $input,
            'data-test' => $input,
            'aria-label' => $input,
          ],
          vec[$input],
        );
        expect(await $element->toHTMLStringAsync())->toEqual(
          '<example title="'.
          $escaped.
          '" data-test="'.
          $escaped.
          '" aria-label="'.
          $escaped.
          '">'.
          $escaped.
          '</example>',
        );
      },
    );
  }
  return $chain;
}

final xhp class UTF8Element extends SGMLStream\RootElement {
  use SGMLStream\ElementWithOpenAndCloseTags;
  const ctx INITIALIZATION_CTX = [];
  const string TAG_NAME = 'example';

  attribute string title;
}
