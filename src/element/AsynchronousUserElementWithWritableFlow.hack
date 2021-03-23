namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * Base class for tags that must await something first, before composing
 * children. If you don't need to await something, use
 * SimpleUserElementWithWritableFlow. AsynchronousUserElementWithWritableFlow
 * comes with an extra runtime cost. It checks if your Awaitable is done, to
 * inform the Consumer that there is some dead time. If your composeAsync method
 * does not await anything, this check will always return true, wasting some
 * cycles checking for it.
 *
 * Because you may write to your Flow, a copy is made for you and your children.
 * If you never write to your copy, this copy was made for nothing. Use
 * AsynchronousUserElement instead if you don't intend to write to your Flow.
 */
abstract xhp class AsynchronousUserElementWithWritableFlow extends RootElement {
  private bool $hasBeenStreamed = false;

  /**
   * Return your representation by composing something Streamable. You may not
   * call methods on the Flow after your returned Awaitable resolves.
   */
  abstract protected function composeAsync(
    SGMLStreamInterfaces\WritableFlow $flow,
  ): Awaitable<SGMLStreamInterfaces\Streamable>;

  <<__Override>>
  final public function placeIntoSnippetStream(
    SGMLStreamInterfaces\SnippetStream $stream,
  ): void {
    if ($this->hasBeenStreamed) {
      throw new _Private\UseAfterRenderException(static::class);
    }
    $this->hasBeenStreamed = true;
    $stream->addSnippet(
      new AwaitableSnippet(
        async $flow ==> $stream->streamOf(
          await $this->composeAsync($flow->makeCopyForChild()),
        ),
      ),
    );
  }
}
