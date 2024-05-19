/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * Base class for tags that depend on reading something from the successor flow.
 * If you do not need to read a value from the successor flow, do not extend
 * this class. You should use AsynchronousElementWithWritableFlow in that
 * case.
 *
 * This class gives you access to the successor flow in `->composeAsync()`.
 * This is useful when you intend to emit content that depends on some data
 * predecessors have placed there. Your `->composeAsync()` call is delayed until
 * every predecessor has rendered and the content bytes that are emitted ahead
 * of your element have been consumed. You are guaranteed to observe every
 * write operation of your predecessors and the none of the write operations of
 * your successors.
 *
 * This synchronization prevents a lot of useful concurrency. All asynchronous
 * operations you execute in `->composeAsync()` or inside your children will not
 * start until every byte that should be emitted ahead of you has been consumed.
 *
 * Use this class sparingly!
 */
abstract xhp class AsynchronousElementWithSuccessorFlow extends RootElement {
  const ctx INITIALIZATION_CTX = [];
  private bool $hasBeenStreamed = false;

  /**
   * Return your representation by composing something Streamable. You may not
   * call methods on the Flow after your returned Awaitable resolves.
   */
  abstract protected function composeAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\WritableFlow>
      $descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $init_flow,
    SGMLStreamInterfaces\Successor<SGMLStreamInterfaces\WritableFlow>
      $successor_flow,
  )[defaults]: Awaitable<SGMLStreamInterfaces\Streamable>;

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
      new AwaitableSnippetWithSuccessorFlow(
        async ($descendant_flow, $successor_flow) ==> {
          $descendant_flow = $descendant_flow->makeCopyForChild();
          $stream = $stream->streamOf(
            await $this->composeAsync(
              $descendant_flow,
              $init_flow,
              $successor_flow,
            ),
            $init_flow,
          );
          return tuple($stream, $descendant_flow);
        },
      ),
    );
  }
}
