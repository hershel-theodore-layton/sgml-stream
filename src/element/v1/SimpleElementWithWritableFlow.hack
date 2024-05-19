/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * Base class for tags that compose children without a need for `await`.
 * The children you compose can be asynchronous.
 * If you need to await something at this level in the tree, see
 * AsynchronousElementWithWritableFlow.
 *
 * Because you may write to your Flow, a copy is made for you and your children.
 * If you never write to your copy, this copy was made for nothing. Use
 * SimpleElement instead if you don't intend to write to your Flow.
 */
abstract class SimpleElementWithWritableFlow
  extends RootElement
  implements SGMLStreamInterfaces\CanProcessSuccessorFlow {
  const ctx INITIALZATION_CTX = [];
  private bool $hasBeenStreamed = false;

  /**
   * Return your representation by composing something Streamable. You may not
   * call methods on the Flow after the method call completes.
   */
  abstract protected function render(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\WritableFlow>
      $descendant_flow,
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
    $stream->addSnippet(new ComposableSnippet(
      $this,
      $descendant_flow ==> {
        $descendant_flow = $descendant_flow->makeCopyForChild();
        $stream = $stream->streamOf(
          $this->render($descendant_flow, $init_flow),
          $init_flow,
        );
        return tuple($stream, $descendant_flow);
      },
    ));
  }
}
