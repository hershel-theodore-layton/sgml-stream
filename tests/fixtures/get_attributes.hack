/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

function get_attributes(
  \HTL\SGMLStream\RootElement $element,
)[]: (dict<string, mixed>, dict<string, mixed>) {
  return tuple(
    $element->getDeclaredAttributes(),
    $element->getDataAndAriaAttributes(),
  );
}
