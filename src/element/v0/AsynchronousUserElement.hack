/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * @deprecated Kept for backwards compatibility with v0.x.
 *
 * Any `AsynchronousUserElement` can be expressed as an `AsynchronousElement`.
 * Please consider using `AsynchronousElement` for new code.
 */
abstract xhp class AsynchronousUserElement extends AsynchronousElement {
  use IgnoreSuccessorFlow;

  /**
   * Return your representation by composing something Streamable. You may not
   * call methods on the Flow after your returned Awaitable resolves.
   */
  abstract protected function composeAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\Flow> $descendant_flow,
  )[defaults]: Awaitable<SGMLStreamInterfaces\Streamable>;

  <<__Override>>
  final protected async function renderAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\Flow> $descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  )[defaults]: Awaitable<SGMLStreamInterfaces\Streamable> {
    return await $this->composeAsync($descendant_flow);
  }
}
