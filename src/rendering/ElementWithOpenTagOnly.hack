/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HH\Lib\C;
use namespace HTL\SGMLStreamInterfaces;

trait ElementWithOpenTagOnly {
  require extends RootElement;
  private bool $hasBeenStreamed = false;

  /**
   * For `<br>`, use `br`. For `<img>`, use `img`.
   */
  <<_Private\UnstableAPI(
    'This property is intended to mimic a constant. Constants in traits are '.
    'supported since https://hhvm.com/blog/2021/02/16/hhvm-4.97.html',
  )>>
  protected string $tagName;

  final public function placeIntoSnippetStream(
    SGMLStreamInterfaces\SnippetStream $stream,
  ): void {
    if ($this->hasBeenStreamed) {
      throw new _Private\UseAfterRenderException(static::class);
    }
    $this->hasBeenStreamed = true;

    $opening_tag = render_opening_tag(
      $this->tagName,
      $this->getDataAndAriaAttributes(),
      $this->getDeclaredAttributes(),
    );

    $stream->addSafeSGML($opening_tag);

    $children = $this->getChildren();
    invariant(
      C\is_empty($children),
      '%s may not have children, got %d children',
      static::class,
      C\count($children),
    );
  }
}
