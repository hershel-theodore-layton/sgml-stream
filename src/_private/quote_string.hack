/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\_Private;

/**
 * `\var_export_pure()` is not present on all supported platforms.
 */
function quote_string(string $value): string {
  return \var_export($value, true);
}
