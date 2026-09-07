/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\SGMLStream;

final xhp class herp_and_derp extends SGMLStream\RootElement {
  use SGMLStream\ElementWithOpenAndCloseTags;
  const ctx INITIALIZATION_CTX = [];

  attribute
    string herp,
    float derp;

  protected string $tagName = 'herp_and_derp';
  const string TAG_NAME = 'herp_and_derp';
}
