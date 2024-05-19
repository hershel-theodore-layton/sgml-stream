/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\SGMLStream;

final xhp class rawtext extends SGMLStream\RootElement {
  const ctx INITIALIZATION_CTX = [];
  const string TAG_NAME = 'rawtext';

  use SGMLStream\ElementWithOpenAndCloseTagsAndUnescapedContent;
}
