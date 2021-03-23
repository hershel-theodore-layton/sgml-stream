namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * Base class for tags that compose children without a need for `await`.
 * The children you compose can be asynchronous.
 * If you need to await something at this level in the tree, see
 * AsynchronousUserElementWithWritableFlow.
 *
 * Because you may write to your Flow, a copy is made for you and your children.
 * If you never write to your copy, this copy was made for nothing. Use
 * SimpleUserElement instead if you don't intend to write to your Flow.
 */
abstract xhp class SimpleUserElementWithWritableFlow extends RootElement {
  private bool $hasBeenStreamed = false;

  /**
   * Return your representation by composing something Streamable. You may not
   * call methods on the Flow after the method call completes.
   */
  abstract protected function compose(
    SGMLStreamInterfaces\WritableFlow $flow,
  ): SGMLStreamInterfaces\Streamable;

  <<__Override>>
  final public function placeIntoSnippetStream(
    SGMLStreamInterfaces\SnippetStream $stream,
  ): void {
    if ($this->hasBeenStreamed) {
      throw new _Private\UseAfterRenderException(static::class);
    }
    $this->hasBeenStreamed = true;
    $stream->addSnippet(new ComposableSnippet(
      $flow ==> $stream->streamOf($this->compose($flow->makeCopyForChild())),
    ));
  }
}
