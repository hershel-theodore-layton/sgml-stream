/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

final xhp class herp_lateinit extends \HTL\SGMLStream\RootElement {
  use \HTL\SGMLStream\ElementWithOpenAndCloseTags;
  const ctx INITIALIZATION_CTX = [];

  attribute string herp @lateinit;

  protected string $tagName = 'herp_lateinit';
  const string TAG_NAME = 'herp_lateinit';
}
