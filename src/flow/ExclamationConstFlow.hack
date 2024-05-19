/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HH\Lib\{C, Dict};
use namespace HTL\SGMLStreamInterfaces;

/**
 * This Flow requires that constants start with a `!` and variables start with
 * any other byte. This frees up the implementation to store constants and
 * variables in the same Container. This Flow prohibits modification after a
 * copy was made.
 */
final class ExclamationConstFlow implements SGMLStreamInterfaces\CopyableFlow {
  private bool $hasBeenCopied = false;

  private function __construct(private dict<string, mixed> $data)[] {}

  public static function createEmpty()[]: SGMLStreamInterfaces\Chameleon<this> {
    return
      SGMLStreamInterfaces\cast_to_chameleon__DO_NOT_USE(new static(dict[]));
  }

  public static function createWithConstantsAndVariables(
    dict<string, mixed> $constants,
    dict<string, mixed> $variables,
  )[]: SGMLStreamInterfaces\Chameleon<this> {
    foreach ($constants as $c => $_) {
      invariant(
        $c[0] === '!',
        'Constants must start with an `!`, got "%s"',
        $c,
      );
    }
    foreach ($variables as $v => $_) {
      invariant(
        $v[0] !== '!',
        'Variables may not start with an `!`, this is reserved from constants, got "%s"',
        $v,
      );
    }
    return SGMLStreamInterfaces\cast_to_chameleon__DO_NOT_USE(
      new static(Dict\merge($constants, $variables)),
    );
  }

  public function assignVariable(string $key, mixed $value)[write_props]: void {
    $this->noUseAfterCopy();
    invariant(
      $key[0] !== '!',
      'Variables may not start with an `!`, this is reserved from constants, got "%s"',
      $key,
    );
    $this->data[$key] = $value;
  }

  public function declareConstant(
    string $key,
    mixed $value,
  )[write_props]: void {
    $this->noUseAfterCopy();
    invariant($key[0] === '!', 'Constants must with an `!`, got "%s"', $key);
    if (C\contains_key($this->data, $key)) {
      throw new _Private\RedeclaredConstantException($key, 'constant');
    }
    $this->data[$key] = $value;
  }

  public function get(string $key)[]: mixed {
    return $this->data[$key] ?? null;
  }

  public function getx(string $key)[]: mixed {
    try {
      return $this->data[$key];
    } catch (\OutOfBoundsException $_) {
      throw new _Private\ValueNotPresentException($key);
    }
  }

  public function has(string $key)[]: bool {
    return C\contains_key($this->data, $key);
  }

  public function makeCopyForChild()[write_props]: this {
    $this->hasBeenCopied = true;
    return new static($this->data);
  }

  private function noUseAfterCopy()[]: void {
    invariant(
      !$this->hasBeenCopied,
      'Can not modify %s after a copy has been made',
      static::class,
    );
  }
}
