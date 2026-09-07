/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\SGMLStream;
use type XHPChild;

function get_children(SGMLStream\RootElement $element)[]: vec<XHPChild> {
  return $element->getChildren();
}
