/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;
use type StringishObject;
use function htmlspecialchars;

function render_opening_tag(
  string $tag,
  dict<string, arraykey> $data_and_aria,
  dict<string, nonnull> $declared_attributes,
)[defaults]: string {
  $out = '<'.$tag;

  foreach ($declared_attributes as $key => $value) {
    if ($value === SGMLStreamInterfaces\SET) {
      // valueless BooleanAttribute
      $out .= ' '.$key;
    } else {
      $stringified_value =
        $value is StringishObject ? $value->__toString() : (string)$value;
      $out .= ' '.$key.'="'.htmlspecialchars($stringified_value).'"';
    }
  }

  foreach ($data_and_aria as $key => $value) {
    $out .= ' '.$key.'="'.htmlspecialchars((string)$value).'"';
  }

  $out .= '>';
  return $out;
}
