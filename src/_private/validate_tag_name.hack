/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\_Private;

use namespace HH\Lib\Str;
use namespace HTL\SGMLStreamInterfaces;

function validate_tag_name(
  classname<SGMLStreamInterfaces\Element> $classname,
  string $property_value,
  string $constant_value,
): void {
  if ($property_value !== $constant_value) {
    \trigger_error(
      Str\format(
        "\$this->tagName does not match static::TAG_NAME in %s.\n".
        " - property value: %s\n - constant value: %s\n".
        "Assigning new values to \$this->tagName is not supported.\n".
        'The value of $this->tagName will be used, but future versions will '.
        'use the value of the TAG_NAME class constant.',
        $classname,
        quote_string($property_value),
        quote_string($constant_value),
      ),
      \E_USER_WARNING,
    );
  }
}
