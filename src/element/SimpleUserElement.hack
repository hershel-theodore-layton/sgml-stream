namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * Base class for tags that compose children without a need for `await`.
 * The children you compose can still be asynchronous. If you need to await
 * something at this level in the tree, see AsynchronousUserElement.
 *
 * You don't get write access to your Flow. If you need write access, see
 * SimpleUserElementWithWritableFlow.
 */
abstract xhp class SimpleUserElement extends RootElement {
  protected bool $hasBeenStreamed = false;

  /**
   * Return your representation by composing something Streamable. You may not
   * call methods on the Flow after the method call completes.
   */
  abstract protected function compose(
    SGMLStreamInterfaces\Flow $flow,
  ): SGMLStreamInterfaces\Streamable;

  <<__Override>>
  final public function placeIntoSnippetStream(
    SGMLStreamInterfaces\SnippetStream $stream,
  ): void {
    invariant(!$this->hasBeenStreamed, '%s was streamed twice', static::class);
    $this->hasBeenStreamed = true;
    $stream->addSnippet(
      new ComposableSnippet($flow ==> $stream->streamOf($this->compose($flow))),
    );
  }
}
