/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\SGMLStream;

final xhp class herp_without_default_and_derp_defaulted
  extends SGMLStream\RootElement {
  use SGMLStream\ElementWithOpenAndCloseTags;
  const ctx INITIALIZATION_CTX = [];

  attribute
    string herp,
    string derp = 'default';

  protected string $tagName = 'herp_without_default_and_derp_defaulted';
  const string TAG_NAME = 'herp_without_default_and_derp_defaulted';
}
