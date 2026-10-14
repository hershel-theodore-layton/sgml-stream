/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;
use function htmlspecialchars;
use const ENT_COMPAT, ENT_SUBSTITUTE;

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
      // `(string) $value` may cast a `StringishObject`.
      // This has not been removed from HHVM just yet.
      // `StringishObject` is supported in HHVM version 4.115 and above.
      // When this cast starts failing at runtime, support for legacy HHVM
      // versions will have to be dropped.
      $out .= ' '.
        $key.
        '="'.
        htmlspecialchars((string)$value, ENT_COMPAT | ENT_SUBSTITUTE, 'UTF-8').
        '"';
    }
  }

  foreach ($data_and_aria as $key => $value) {
    $out .= ' '.
      $key.
      '="'.
      htmlspecialchars((string)$value, ENT_COMPAT | ENT_SUBSTITUTE, 'UTF-8').
      '"';
  }

  $out .= '>';
  return $out;
}
