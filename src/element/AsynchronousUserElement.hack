namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * Base class for tags that must await something first, before composing
 * children. If you don't need to await something, use SimpleUserElement.
 * AsynchronousUserElement comes with an extra runtime cost. It checks if your
 * Awaitable is done, to inform the Consumer that there is some dead time. If
 * your composeAsync method does not await anything, this check will always
 * return false, wasting some cycles checking for it.
 *
 * You don't get write access to your Flow. If you need write access, see
 * AsynchronousUserElementWithWritableFlow.
 */
abstract xhp class AsynchronousUserElement extends RootElement {
  protected bool $hasBeenStreamed = false;

  /**
   * Return your representation by composing something Streamable. You may not
   * call methods on the Flow after your returned Awaitable resolves.
   */
  abstract protected function composeAsync(
    SGMLStreamInterfaces\Flow $flow,
  ): Awaitable<SGMLStreamInterfaces\Streamable>;

  <<__Override>>
  final public function placeIntoSnippetStream(
    SGMLStreamInterfaces\SnippetStream $stream,
  ): void {
    invariant(!$this->hasBeenStreamed, '%s was streamed twice', static::class);
    $this->hasBeenStreamed = true;
    $stream->addSnippet(
      new AwaitableSnippet(
        async $flow ==> $stream->streamOf(await $this->composeAsync($flow)),
      ),
    );
  }
}
