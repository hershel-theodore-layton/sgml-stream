/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * @deprecated Kept for backwards compatibility with v0.x.
 *
 * Base class for tags that compose children without a need for `await`.
 * The children you compose can still be asynchronous. If you need to await
 * something at this level in the tree, see AsynchronousUserElement.
 *
 * You don't get write access to your Flow. If you need write access, see
 * SimpleUserElementWithWritableFlow.
 *
 * If you do not depend on the Flow at all and your element is pure, you can
 * look at DissolvableUserElement. This reduces the amount of wrapping objects
 * created and moves the processing in compose() to an earlier stage of the
 * rendering process. You should NOT do this if your processing is expensive
 * or depends on global state.
 */
abstract xhp class SimpleUserElement extends RootElement {
  private bool $hasBeenStreamed = false;

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
    if ($this->hasBeenStreamed) {
      throw new _Private\UseAfterRenderException(static::class);
    }
    $this->hasBeenStreamed = true;
    $stream->addSnippet(
      new ComposableSnippet($flow ==> $stream->streamOf($this->compose($flow))),
    );
  }
}
