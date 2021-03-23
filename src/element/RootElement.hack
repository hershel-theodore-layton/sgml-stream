namespace HTL\SGMLStream;

use namespace HH\Lib\{C, Str};
use namespace HTL\SGMLStreamInterfaces;
use type XHPChild;

abstract xhp class RootElement
  implements SGMLStreamInterfaces\Streamable, SGMLStreamInterfaces\Element {
  // Must be kept in sync with xhp-lib
  const string SPREAD_PREFIX = '...$';

  private dict<string, nonnull> $attributes;
  private dict<string, arraykey> $dataAndAria;
  private vec<XHPChild> $children = vec[];

  /**
   * Virtual pseudo constructor. Invoked after attribute+child initialization.
   */
  protected function init(): void {}

  <<SGMLStreamInterfaces\HHVMSignature('<p id="a">...</p>')>>
  final public function __construct(
    KeyedTraversable<string, mixed> $attributes,
    Traversable<?XHPChild> $children,
    dynamic ...$debug_info
  ) {
    $this->initializeAttributes($attributes);
    $this->appendXHPChildren($children);
    $this->init();
  }

  <<SGMLStreamInterfaces\HHVMSignature('$xhp->:prop')>>
  final public function getAttribute(string $attr): mixed {
    return $this->attributes[$attr] ?? $this->dataAndAria[$attr] ?? null;
  }

  /**
   * Explicitly virtual to allow application developers to choose other
   * implementations of SnippetStream, Renderer, Consumer, and Flow.
   */
  public async function toHTMLStringAsync(): Awaitable<string> {
    $stream = new ConcatenatingStream();
    $this->placeIntoSnippetStream($stream);
    $renderer = new ConcurrentSingleUseRenderer($stream);
    $consumer = new ToStringConsumer();
    $flow = FirstComeFirstServedFlow::createEmpty();
    await $renderer->renderAsync($consumer, $flow);
    return $consumer->toString();
  }

  final protected function getChildren(): vec<XHPChild> {
    return $this->children;
  }

  final protected function getDataAndAriaAttributes(): dict<string, arraykey> {
    return $this->dataAndAria;
  }

  final protected function getDeclaredAttributes(): dict<string, nonnull> {
    return $this->attributes;
  }

  final protected function placeMyChildrenIntoSnippetStream(
    SGMLStreamInterfaces\SnippetStream $stream,
  ): void {
    foreach ($this->getChildren() as $child) {
      if ($child is SGMLStreamInterfaces\Streamable) {
        $child->placeIntoSnippetStream($stream);
      } else if ($child is Traversable<_>) {
        self::placeTraversableIntoSnippetStream($stream, $child);
      } else if ($child is SGMLStreamInterfaces\ToSGMLStringAsync) {
        $stream->addSnippet(new ToSGMLStringAsyncSnippet($child));
      } else /*if ($child is scalar) */ {
        $stream->addSafeSGML(self::htmlSpecialChars($child));
      }
    }
  }

  final protected static function placeTraversableIntoSnippetStream(
    SGMLStreamInterfaces\SnippetStream $stream,
    Traversable<mixed> $children,
  ): void {
    foreach ($children as $child) {
      if ($child is SGMLStreamInterfaces\Streamable) {
        $child->placeIntoSnippetStream($stream);
      } else if ($child is Traversable<_>) {
        self::placeTraversableIntoSnippetStream($stream, $child);
      } else if ($child is SGMLStreamInterfaces\ToSGMLStringAsync) {
        $stream->addSnippet(new ToSGMLStringAsyncSnippet($child));
      } else if ($child is null) {
        // ignore
      } else /*if ($child is scalar) */ {
        $stream->addSafeSGML(self::htmlSpecialChars($child));
      }
    }
  }

  /**
   * Emitted by HHVM for `xhp_simple_attribute` and `xhp_simple_class_attribute`.
   * Allows to get attributes declared on a class.
   */
  <<SGMLStreamInterfaces\HHVMSignature('attribute string alt = ""')>>
  protected static function __xhpAttributeDeclaration(
  ): darray<string, varray<mixed>> {
    return darray[];
  }

  private function appendXHPChildren(Traversable<?XHPChild> $children): void {
    foreach ($children as $child) {
      if ($child is SGMLStreamInterfaces\FragElement) {
        $this->appendXHPChildren($child->getChildren());
      } else if ($child is Traversable<_>) {
        $this->appendTraversable($child);
      } else if ($child is nonnull) {
        $this->children[] = $child;
      }
    }
  }

  private function appendTraversable(Traversable<mixed> $children): void {
    foreach ($children as $child) {
      if ($child is SGMLStreamInterfaces\FragElement) {
        $this->appendXHPChildren($child->getChildren());
      } else if ($child is Traversable<_>) {
        $this->appendTraversable($child);
      } else if ($child is XHPChild) {
        $this->children[] = $child;
      } else {
        invariant(
          $child is null,
          'A %s contained a non-XHPChild. '.
          'All children must be an XHPChild. '.
          'AnyArray<_, _> unconditionally implements XHPChild, '.
          'even when Tv is not a subtype of XHPChild. '.
          'This is the reason why the typechecker did not catch this error.',
          self::typeName($child),
        );
      }
    }
  }

  <<__MemoizeLSB>>
  private static function defaultAttributes(
  ): (dict<string, nonnull>, dict<string, arraykey>) {
    $attributes = dict[];
    $data_and_aria = dict[];
    foreach (static::__xhpAttributeDeclaration() as $key => $info) {
      $value = $info[2];
      if ($value is nonnull) {
        if (self::isDataOrAria($key)) {
          invariant(
            $value is arraykey,
            'data- and aria- attributes may only have arraykey values. '.
            'The default value of xhp class %s { attribute %s %s = ...; } is '.
            'not an arraykey.',
            static::class,
            self::typeName($value),
            $key,
          );
          $data_and_aria[$key] = $value;
        } else {
          $attributes[$key] = $value;
        }
      }
    }
    return tuple($attributes, $data_and_aria);
  }

  private static function hasAttribute(string $attr): bool {
    return C\contains_key(static::__xhpAttributeDeclaration(), $attr);
  }

  private static function htmlSpecialChars(mixed $scalar): string {
    invariant(
      \is_scalar($scalar),
      '%s does not implement %s, and can not be implicitly htmlspecialchars-ed',
      self::typeName($scalar),
      SGMLStreamInterfaces\Element::class,
    );
    return \htmlspecialchars((string)$scalar);
  }

  private function initializeAttributes(
    KeyedTraversable<string, mixed> $attributes,
  ): void {
    // Initialization of attributes:
    // - Put the default values at the front.
    //   They can be overwritten by explicit values.
    // - If we get an explicit null, remove the attribute if it was set.
    //   We don't want store nulls, since this would create an observable
    //   difference between an explicit null and something that was not set.
    // - Store `data-` and `aria-` in their own dict.
    //   Enforce that they must be arraykey, since we don't
    //   want them to become unofficial expandos.
    // - If we get a spread, copy all the nonnull values over
    //   and ignore the null values.

    list($this->attributes, $this->dataAndAria) = self::defaultAttributes();
    foreach ($attributes as $key => $value) {
      if ($value is null) {
        if (self::isDataOrAria($key)) {
          if (C\contains_key($this->dataAndAria, $key)) {
            unset($this->dataAndAria[$key]);
          }
        } else {
          // We don't check for the spread operator here.
          // Spreading null is a typechecker error.
          // If this error is fixme'd, this is a noop anyway.
          if (C\contains_key($this->attributes, $key)) {
            unset($this->attributes[$key]);
          }
        }
      } else {
        if (self::isSpreadOperator($key)) {
          $this->spread($value);
        } else if (self::isDataOrAria($key)) {
          invariant(
            $value is arraykey,
            'data- and aria- attributes may only have arraykey values. '.
            'Value passed for <%s %s={...} /> is %s.',
            static::class,
            $key,
            self::typeName($value),
          );
          $this->dataAndAria[$key] = $value;
        } else {
          $this->attributes[$key] = $value;
        }
      }
    }
  }

  private function spread(mixed $other): void {
    invariant(
      $other is SGMLStreamInterfaces\Element,
      'Spread source %s does not implement %s. '.
      'If this is an xhp object from a different xhp library. '.
      'You might want to implement it to allow spreading into %s.',
      self::typeName($other),
      SGMLStreamInterfaces\Element::class,
      static::class,
    );
    foreach ($other->getDataAndAriaAttributes() as $key => $value) {
      $this->dataAndAria[$key] = $value;
    }

    foreach ($other->getDeclaredAttributes() as $key => $value) {
      if (self::hasAttribute($key)) {
        $this->attributes[$key] = $value;
      }
    }
  }

  private static function isDataOrAria(string $key): bool {
    return Str\starts_with($key, 'data-') || Str\starts_with($key, 'aria-');
  }

  private static function isSpreadOperator(string $key): bool {
    return Str\starts_with($key, self::SPREAD_PREFIX);
  }

  private static function typeName(mixed $mixed): string {
    return \is_object($mixed) ? \get_class($mixed) : \gettype($mixed);
  }

  ////////////////////////////////////////////////////
  //// Pretend this stuff doesn't exist.          ////
  //// These methods start with two underscores.  ////
  //// HHVM may emit similarly named methods.     ////
  //// I WILL THROW AN `\Error` IF YOU CALL THEM. ////
  //// If HHVM calls them internally, ¯\_(ツ)_/¯. ////
  ////////////////////////////////////////////////////

  final protected function __flushSubtree(): Awaitable<nothing> {
    return _Private\hhvm_may_want_this_method();
  }

  <<__MemoizeLSB>>
  final public static function __xhpReflectionAttributes(
  ): dict<string, nothing> {
    return _Private\hhvm_may_want_this_method();
  }

  protected static function __legacySerializedXHPChildrenDeclaration(): mixed {
    return _Private\hhvm_may_want_this_method();
  }

  <<__MemoizeLSB>>
  final public static function __xhpReflectionChildrenDeclaration(): nothing {
    return _Private\hhvm_may_want_this_method();
  }

  final public static function __xhpReflectionCategoryDeclaration(
  ): keyset<string> {
    return _Private\hhvm_may_want_this_method();
  }

  protected function __xhpChildrenDeclaration(): mixed {
    return _Private\hhvm_may_want_this_method();
  }

  public function __getChildrenDeclaration(): string {
    return _Private\hhvm_may_want_this_method();
  }

  final public function __getChildrenDescription(): string {
    return _Private\hhvm_may_want_this_method();
  }
}
