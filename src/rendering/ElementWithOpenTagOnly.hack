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
  abstract const string TAG_NAME;

  final public function placeIntoSnippetStream(
    SGMLStreamInterfaces\SnippetStream $stream,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  )[defaults]: void {
    if ($this->hasBeenStreamed) {
      throw new _Private\UseAfterRenderException(static::class);
    }
    $this->hasBeenStreamed = true;

    $opening_tag = render_opening_tag(
      static::TAG_NAME,
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
