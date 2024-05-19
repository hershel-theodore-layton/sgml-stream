/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * Base class for tags that must await something first, before composing
 * children. If you don't need to await something, use
 * SimpleElementWithWritableFlow. AsynchronousElementWithWritableFlow
 * comes with an extra runtime cost. It checks if your Awaitable is done, to
 * inform the Consumer that there is some dead time. If your renderAsync method
 * does not await anything, this check will always return true, wasting some
 * cycles checking for it.
 *
 * Because you may write to your Flow, a copy is made for you and your children.
 * If you never write to your copy, this copy was made for nothing. Use
 * AsynchronousElement instead if you don't intend to write to your Flow.
 */
abstract class AsynchronousElementWithWritableFlow
  extends RootElement
  implements SGMLStreamInterfaces\CanProcessSuccessorFlow {
  const ctx INITIALZATION_CTX = [];
  private bool $hasBeenStreamed = false;

  /**
   * Return your representation by composing something Streamable. You may not
   * call methods on the Flow after your returned Awaitable resolves.
   */
  abstract protected function renderAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\WritableFlow>
      $descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $init_flow,
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
      new AwaitableSnippet(
        $this,
        async $descendant_flow ==> {
          $descendant_flow = $descendant_flow->makeCopyForChild();
          $stream = $stream->streamOf(
            await $this->renderAsync($descendant_flow, $init_flow),
            $init_flow,
          );
          return tuple($stream, $descendant_flow);
        },
      ),
    );
  }
}
