/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * Base class for tags that compose children without a need for `await`.
 * The children you compose can still be asynchronous. If you need to await
 * something at this level in the tree, see AsynchronousElement.
 *
 * You don't get write access to your Flow. If you need write access, see
 * SimpleElementWithWritableFlow.
 *
 * If you do not depend on the Flow at all and your element is
 * conceptually pure, you can look at DissolvableElement. This reduces the
 * amount of wrapping objects created and moves the processing in render() to an
 * earlier stage of the rendering process. You should NOT do this if your
 * processing is expensive or depends on global state.
 */
abstract xhp class SimpleElement
  extends RootElement
  implements SGMLStreamInterfaces\CanProcessSuccessorFlow {
  const ctx INITIALIZATION_CTX = [];
  private bool $hasBeenStreamed = false;

  /**
   * Return your representation by composing something Streamable. You may not
   * call methods on the Flow after the method call completes.
   */
  abstract protected function render(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\Flow> $descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $init_flow,
  )[defaults]: SGMLStreamInterfaces\Streamable;

  <<__Override>>
  final public function placeIntoSnippetStream(
    SGMLStreamInterfaces\SnippetStream $stream,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $init_flow,
  )[defaults]: void {
    if ($this->hasBeenStreamed) {
      throw new _Private\UseAfterRenderException(static::class);
    }
    $this->hasBeenStreamed = true;
    $stream->addSnippet(
      new ComposableSnippet(
        $this,
        $descendant_flow ==> tuple(
          $stream->streamOf(
            $this->render($descendant_flow, $init_flow),
            $init_flow,
          ),
          $descendant_flow,
        ),
      ),
    );
  }
}
