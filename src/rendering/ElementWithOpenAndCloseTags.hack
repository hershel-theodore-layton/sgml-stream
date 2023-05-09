/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

trait ElementWithOpenAndCloseTags {
  require extends RootElement;
  private bool $hasBeenStreamed = false;

  /**
   * For `<div>`, use `div`. For `<span>`, use `span`.
   */
  abstract const string TAG_NAME;

  final public function placeIntoSnippetStream(
    SGMLStreamInterfaces\SnippetStream $stream,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $init_flow,
  ): void {
    if ($this->hasBeenStreamed) {
      throw new _Private\UseAfterRenderException(static::class);
    }
    $this->hasBeenStreamed = true;

    $stream->addSafeSGML(
      render_opening_tag(
        static::TAG_NAME,
        $this->getDataAndAriaAttributes(),
        $this->getDeclaredAttributes(),
      ),
    );
    $this->placeMyChildrenIntoSnippetStream($stream, $init_flow);
    $stream->addSafeSGML('</'.static::TAG_NAME.'>');
  }
}
