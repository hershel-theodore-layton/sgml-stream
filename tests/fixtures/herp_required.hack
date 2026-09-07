/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\SGMLStream;

final xhp class herp_required extends SGMLStream\RootElement {
  use SGMLStream\ElementWithOpenAndCloseTags;
  const ctx INITIALIZATION_CTX = [];

  attribute string herp @required;

  protected string $tagName = 'herp_required';
  const string TAG_NAME = 'herp_required';
}
