/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\SGMLStream;

final xhp class herp_defaulted extends SGMLStream\RootElement {
  use SGMLStream\ElementWithOpenAndCloseTags;
  const ctx INITIALIZATION_CTX = [];

  attribute string herp = 'default';

  protected string $tagName = 'herp_defaulted';
  const string TAG_NAME = 'herp_defaulted';
}
