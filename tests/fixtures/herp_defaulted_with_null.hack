/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

final xhp class herp_defaulted_with_null extends \HTL\SGMLStream\RootElement {
  use \HTL\SGMLStream\ElementWithOpenAndCloseTags;
  const ctx INITIALIZATION_CTX = [];

  attribute string herp = null;

  protected string $tagName = 'herp_defaulted_with_null';
  const string TAG_NAME = 'herp_defaulted_with_null';
}
