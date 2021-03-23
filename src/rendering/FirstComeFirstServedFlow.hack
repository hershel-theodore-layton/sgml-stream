namespace HTL\SGMLStream;

use namespace HH\Lib\C;
use namespace HTL\SGMLStreamInterfaces;

/**
 * This Flow is very permissive. It allows use after copy and mixes variables
 * and constants within the same namespace. I'd urge you to at least check out
 * ExclamationConstFlow or write something else. This Flow was made for the
 * purpose of being an unopinionated Flow for RootElement->toHTMLStringAsync(),
 * since no explicit Flow can be provided by the caller.
 */
final class FirstComeFirstServedFlow
  implements SGMLStreamInterfaces\CopyableFlow {

  private function __construct(
    private dict<string, mixed> $constants,
    private dict<string, mixed> $variables,
  ) {}

  public static function createEmpty(): this {
    return new static(dict[], dict[]);
  }

  public static function createWithConstantsAndVariables(
    dict<string, mixed> $constants,
    dict<string, mixed> $variables,
  ): this {
    return new static($constants, $variables);
  }

  public function assignVariable(string $key, mixed $value): void {
    if (C\contains_key($this->constants, $key)) {
      throw new _Private\RedeclaredConstantException($key, 'variable');
    }
    $this->variables[$key] = $value;
  }

  public function declareConstant(string $key, mixed $value): void {
    if (
      C\contains_key($this->constants, $key) ||
      C\contains_key($this->variables, $key)
    ) {
      throw new _Private\RedeclaredConstantException($key, 'constant');
    }
    $this->constants[$key] = $value;
  }

  public function get(string $key): mixed {
    return $this->constants[$key] ?? $this->variables[$key] ?? null;
  }

  public function getx(string $key): mixed {
    if (
      !C\contains_key($this->constants, $key) &&
      !C\contains_key($this->variables, $key)
    ) {
      throw new _Private\ValueNotPresentException($key);
    }
    return $this->constants[$key] ?? $this->variables[$key];
  }

  public function has(string $key): bool {
    return C\contains_key($this->constants, $key) ||
      C\contains_key($this->variables, $key);
  }

  public function makeCopyForChild(): this {
    return new static($this->constants, $this->variables);
  }
}
