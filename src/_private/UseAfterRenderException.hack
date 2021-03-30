/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\_Private;

use namespace HTL\SGMLStreamInterfaces;

final class UseAfterRenderException
  extends \Exception
  implements SGMLStreamInterfaces\UseAfterRenderException {
  public function __construct(classname<mixed> $class) {
    parent::__construct($class.' was streamed twice');
  }
}
