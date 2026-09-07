/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\SGMLStream;

function get_attributes(
  SGMLStream\RootElement $element,
)[]: (dict<string, mixed>, dict<string, mixed>) {
  return tuple(
    $element->getDeclaredAttributes(),
    $element->getDataAndAriaAttributes(),
  );
}
