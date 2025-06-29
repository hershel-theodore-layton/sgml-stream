/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

final xhp class herp_and_derp extends \HTL\SGMLStream\RootElement {
  use \HTL\SGMLStream\ElementWithOpenAndCloseTags;
  const ctx INITIALIZATION_CTX = [];

  attribute
    string herp,
    float derp;

  protected string $tagName = 'herp_and_derp';
  const string TAG_NAME = 'herp_and_derp';
}
