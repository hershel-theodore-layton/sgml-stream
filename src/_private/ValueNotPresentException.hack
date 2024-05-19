/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\_Private;

use namespace HTL\SGMLStreamInterfaces;

final class ValueNotPresentException
  extends \Exception
  implements SGMLStreamInterfaces\ValueNotPresentException {
  public function __construct(private string $key)[] {
    parent::__construct(
      'No constant or variable with the name '.$key.' has been declared.',
    );
  }

  public function getKey()[]: string {
    return $this->key;
  }
}
