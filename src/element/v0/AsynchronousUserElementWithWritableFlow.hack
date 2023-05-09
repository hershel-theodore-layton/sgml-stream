/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * @deprecated Kept for backwards compatibility with v0.x.
 *
 * Any `AsynchronousUserElementWithWriteableFlow` can be expressed as an
 * `AsynchronousElementWithWritableFlow`.
 * Please consider using `AsynchronousElement` for new code.
 */
abstract xhp class AsynchronousUserElementWithWritableFlow
  extends AsynchronousElementWithWritableFlow {
  use IgnoreSuccessorFlow;

  /**
   * Return your representation by composing something Streamable. You may not
   * call methods on the Flow after your returned Awaitable resolves.
   */
  abstract protected function composeAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\WritableFlow>
      $descendant_flow,
  ): Awaitable<SGMLStreamInterfaces\Streamable>;

  <<__Override>>
  final protected async function renderAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\WritableFlow>
      $descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  ): Awaitable<SGMLStreamInterfaces\Streamable> {
    return await $this->composeAsync($descendant_flow);
  }
}
