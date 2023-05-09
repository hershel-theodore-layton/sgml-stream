/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * Base class for tags that must await something first, before composing
 * children. If you don't need to await something, use SimpleElement.
 * AsynchronousElement comes with an extra runtime cost. It checks if your
 * Awaitable is done, to inform the Consumer that there is some dead time. If
 * your renderAsync method does not await anything, this check will always
 * return false, wasting some cycles checking for it.
 *
 * You don't get write access to your Flow. If you need write access, see
 * AsynchronousElementWithWritableFlow.
 */
abstract xhp class AsynchronousElement
  extends RootElement
  implements SGMLStreamInterfaces\CanProcessSuccessorFlow {
  private bool $hasBeenStreamed = false;

  /**
   * Return your representation by composing something Streamable. You may not
   * call methods on the Flow after your returned Awaitable resolves.
   */
  abstract protected function renderAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\Flow> $descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $init_flow,
  ): Awaitable<SGMLStreamInterfaces\Streamable>;

  <<__Override>>
  final public function placeIntoSnippetStream(
    SGMLStreamInterfaces\SnippetStream $stream,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $init_flow,
  ): void {
    if ($this->hasBeenStreamed) {
      throw new _Private\UseAfterRenderException(static::class);
    }
    $this->hasBeenStreamed = true;
    $stream->addSnippet(
      new AwaitableSnippet(
        $this,
        async $descendant_flow ==> tuple(
          $stream->streamOf(
            await $this->renderAsync($descendant_flow, $init_flow),
            $init_flow,
          ),
          $descendant_flow,
        ),
      ),
    );
  }
}
