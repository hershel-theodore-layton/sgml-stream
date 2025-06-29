/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use type XHPChild;

function get_children(\HTL\SGMLStream\RootElement $element)[]: vec<XHPChild> {
  return $element->getChildren();
}
