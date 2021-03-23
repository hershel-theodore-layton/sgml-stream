namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

trait ElementWithOpenAndCloseTags {
  require extends RootElement;
  private bool $hasBeenStreamed = false;

  /**
   * For `<div>`, use `div`. For `<span>`, use `span`.
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

    $stream->addSafeSGML(
      render_opening_tag(
        $this->tagName,
        $this->getDataAndAriaAttributes(),
        $this->getDeclaredAttributes(),
      ),
    );
    $this->placeMyChildrenIntoSnippetStream($stream);
    $stream->addSafeSGML('</'.$this->tagName.'>');
  }
}
