/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\_Private;

use namespace HTL\SGMLStreamInterfaces;

final class RedeclaredConstantException
  extends \Exception
  implements SGMLStreamInterfaces\RedeclaredConstantException {
  public function __construct(private string $key, string $what) {
    parent::__construct(
      'You may not declare the '.
      $what.
      ' '.
      $key.
      ', because a constant with the name already exists.',
    );
  }

  public function getKey(): string {
    return $this->key;
  }
}
