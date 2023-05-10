/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\SGMLStream;

final class element extends SGMLStream\RootElement {
  const string TAG_NAME = 'element';

  use SGMLStream\ElementWithOpenAndCloseTags;
}
