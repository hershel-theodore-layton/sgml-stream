/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\SGMLStream;

final xhp class data_special_defaulted extends SGMLStream\RootElement {
  use SGMLStream\ElementWithOpenAndCloseTags;
  const ctx INITIALIZATION_CTX = [];

  attribute string data-special = 'default';

  protected string $tagName = 'data_special_defaulted';
  const string TAG_NAME = 'data_special_defaulted';
}
