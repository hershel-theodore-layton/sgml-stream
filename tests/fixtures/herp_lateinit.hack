/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\SGMLStream;

final xhp class herp_lateinit extends SGMLStream\RootElement {
  use SGMLStream\ElementWithOpenAndCloseTags;
  const ctx INITIALIZATION_CTX = [];

  attribute string herp @lateinit;

  protected string $tagName = 'herp_lateinit';
  const string TAG_NAME = 'herp_lateinit';
}
