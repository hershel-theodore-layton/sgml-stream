/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HH\Lib\{C, Str};
use namespace HTL\SGMLStreamInterfaces;
use type XHPChild;

abstract xhp class RootElement
  implements SGMLStreamInterfaces\Streamable, SGMLStreamInterfaces\Element {
  // Must be kept in sync with xhp-lib
  const string SPREAD_PREFIX = '...$';

  abstract const ctx INITIALIZATION_CTX;

  private dict<string, nonnull> $attributes;
  private dict<string, arraykey> $dataAndAria;
  private vec<XHPChild> $children = vec[];

  /**
   * Virtual pseudo constructor. Invoked after attribute+child initialization.
   */
  protected function init()[this::INITIALIZATION_CTX]: void {}

  <<SGMLStreamInterfaces\HHVMSignature('<p id="a">...</p>')>>
  final public function __construct(
    KeyedTraversable<string, mixed> $attributes,
    Traversable<?XHPChild> $children,
    dynamic ...$_debug_info
  )[this::INITIALIZATION_CTX] {
    list($this->attributes, $this->dataAndAria) =
      self::initializeAttributes($attributes);
    $this->children = self::flattenChildren($children);
    $this->init();
  }

  <<SGMLStreamInterfaces\HHVMSignature('$xhp->:prop')>>
  final public function getAttribute(string $attr)[]: mixed {
    return $this->attributes[$attr] ?? $this->dataAndAria[$attr] ?? null;
  }

  /**
   * Explicitly virtual (non-final) to allow application developers to choose
   * other implementations of SnippetStream, Renderer, Consumer, and Flow.
   */
  public async function toHTMLStringAsync()[defaults]: Awaitable<string> {
    $renderer = new ConcurrentReusableRenderer();
    $consumer = new ToStringConsumer();
    await $renderer->renderAsync(
      new ConcatenatingStream(),
      $this,
      $consumer,
      FirstComeFirstServedFlow::createEmpty(),
      FirstComeFirstServedFlow::createEmpty(),
      FirstComeFirstServedFlow::createEmpty(),
    );
    return $consumer->toString();
  }

  final public function getChildren()[]: vec<XHPChild> {
    return $this->children;
  }

  final public function getDataAndAriaAttributes(
  )[]: dict<string, arraykey> {
    return $this->dataAndAria;
  }

  final public function getDeclaredAttributes()[]: dict<string, nonnull> {
    return $this->attributes;
  }

  final protected function placeMyChildrenIntoSnippetStream(
    SGMLStreamInterfaces\SnippetStream $stream,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $init_flow,
  )[defaults]: void {
    foreach ($this->getChildren() as $child) {
      if ($child is SGMLStreamInterfaces\Streamable) {
        $child->placeIntoSnippetStream($stream, $init_flow);
      } else if ($child is Traversable<_>) {
        self::placeTraversableIntoSnippetStream($stream, $init_flow, $child);
      } else if ($child is SGMLStreamInterfaces\ToSGMLStringAsync) {
        $stream->addSnippet(new ToSGMLStringAsyncSnippet($child));
      } else /*if ($child is scalar) */ {
        $stream->addSafeSGML(self::htmlSpecialChars($child));
      }
    }
  }

  final protected static function placeTraversableIntoSnippetStream(
    SGMLStreamInterfaces\SnippetStream $stream,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $init_flow,
    Traversable<mixed> $children,
  )[defaults]: void {
    foreach ($children as $child) {
      if ($child is SGMLStreamInterfaces\Streamable) {
        $child->placeIntoSnippetStream($stream, $init_flow);
      } else if ($child is Traversable<_>) {
        self::placeTraversableIntoSnippetStream($stream, $init_flow, $child);
      } else if ($child is SGMLStreamInterfaces\ToSGMLStringAsync) {
        $stream->addSnippet(new ToSGMLStringAsyncSnippet($child));
      } else if ($child is nonnull /* $child is scalar */) {
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
  )[]: AnyArray<string, varray<mixed>> {
    return HH4Shim\array_to_shape(dict[]) as AnyArray<_, _>;
  }

  private function appendXHPChildren(
    Traversable<?XHPChild> $children,
  )[write_props]: void {
    foreach ($children as $child) {
      if ($child is SGMLStreamInterfaces\FragElement) {
        foreach ($child->getFragChildren() as $c) {
          $this->children[] = $c;
        }
      } else if ($child is Traversable<_>) {
        $this->appendTraversable($child);
      } else if ($child is nonnull) {
        $this->children[] = $child;
      }
    }
  }

  private function appendTraversable(
    Traversable<mixed> $children,
  )[write_props]: void {
    foreach ($children as $child) {
      if ($child is SGMLStreamInterfaces\FragElement) {
        foreach ($child->getFragChildren() as $c) {
          $this->children[] = $c;
        }
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
  )[]: (dict<string, nonnull>, dict<string, arraykey>) {
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

  private static function hasAttribute(string $attr)[]: bool {
    return C\contains_key(static::__xhpAttributeDeclaration(), $attr);
  }

  private static function htmlSpecialChars(mixed $scalar)[defaults]: string {
    invariant(
      \is_scalar($scalar),
      '%s does not implement %s, and can not be implicitly htmlspecialchars-ed',
      self::typeName($scalar),
      SGMLStreamInterfaces\Element::class,
    );
    return \htmlspecialchars((string)$scalar);
  }

  private static function initializeAttributes(
    KeyedTraversable<string, mixed> $mixed_attributes,
  )[]: (dict<string, nonnull>, dict<string, arraykey>) {
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

    list($attributes, $data_and_aria) = self::defaultAttributes();
    foreach ($mixed_attributes as $key => $value) {
      if ($value is null) {
        if (self::isDataOrAria($key)) {
          if (C\contains_key($data_and_aria, $key)) {
            unset($data_and_aria[$key]);
          }
        } else {
          // We don't check for the spread operator here.
          // Spreading null is a typechecker error.
          // If this error is fixme'd, this is a noop anyway.
          if (C\contains_key($attributes, $key)) {
            unset($attributes[$key]);
          }
        }
      } else if (self::isSpreadOperator($key)) {
        invariant(
          $value is SGMLStreamInterfaces\Element,
          'Spread source %s does not implement %s. '.
          'If this is an xhp object from a different xhp library, '.
          'you might want to implement %s to allow spreading into %s.',
          self::typeName($value),
          SGMLStreamInterfaces\Element::class,
          SGMLStreamInterfaces\Element::class,
          static::class,
        );

        foreach ($value->getDataAndAriaAttributes() as $k => $v) {
          $data_and_aria[$k] = $v;
        }

        foreach ($value->getDeclaredAttributes() as $k => $v) {
          if (self::hasAttribute($k)) {
            $attributes[$k] = $v;
          }
        }
      } else if (self::isDataOrAria($key)) {
        invariant(
          $value is arraykey,
          'data- and aria- attributes may only have arraykey values. '.
          'Value passed for <%s %s={...} /> is %s.',
          static::class,
          $key,
          self::typeName($value),
        );
        $data_and_aria[$key] = $value;
      } else {
        $attributes[$key] = $value;
      }
    }

    return tuple($attributes, $data_and_aria);
  }

  private static function isDataOrAria(string $key)[]: bool {
    return Str\starts_with($key, 'data-') || Str\starts_with($key, 'aria-');
  }

  private static function isSpreadOperator(string $key)[]: bool {
    return Str\starts_with($key, self::SPREAD_PREFIX);
  }

  private static function typeName(mixed $mixed)[]: string {
    return \is_object($mixed) ? \get_class($mixed) : \gettype($mixed);
  }

  private static function flattenChildren(
    Traversable<?XHPChild> $children,
  )[]: vec<XHPChild> {
    $flattened = vec[];

    foreach ($children as $child) {
      if ($child is SGMLStreamInterfaces\FragElement) {
        foreach ($child->getFragChildren() as $c) {
          $flattened[] = $c;
        }
      } else if ($child is Traversable<_>) {
        foreach (self::flattenTraversable($child) as $c) {
          $flattened[] = $c;
        }
      } else if ($child is nonnull) {
        $flattened[] = $child;
      }
    }

    return $flattened;
  }

  private static function flattenTraversable(
    Traversable<mixed> $mixed_children,
  )[]: Traversable<XHPChild> {
    foreach ($mixed_children as $child) {
      if ($child is SGMLStreamInterfaces\FragElement) {
        foreach ($child->getFragChildren() as $c) {
          yield $c;
        }
      } else if ($child is Traversable<_>) {
        foreach (self::flattenTraversable($child) as $c) {
          yield $c;
        }
      } else if ($child is XHPChild) {
        yield $child;
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
}
