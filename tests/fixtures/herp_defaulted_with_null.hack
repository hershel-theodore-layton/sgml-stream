/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\SGMLStream;

final xhp class herp_defaulted_with_null extends SGMLStream\RootElement {
  use SGMLStream\ElementWithOpenAndCloseTags;
  const ctx INITIALIZATION_CTX = [];

  attribute string herp = null;

  protected string $tagName = 'herp_defaulted_with_null';
  const string TAG_NAME = 'herp_defaulted_with_null';
}
