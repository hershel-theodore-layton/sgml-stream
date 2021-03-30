/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\_Private;

use namespace HTL\SGMLStreamInterfaces;

final class SnippetNotPrimedException
  extends \Exception
  implements SGMLStreamInterfaces\SnippetNotPrimedException {
  public function __construct(classname<mixed> $class) {
    parent::__construct($class.' was not primed before use');
  }
}
