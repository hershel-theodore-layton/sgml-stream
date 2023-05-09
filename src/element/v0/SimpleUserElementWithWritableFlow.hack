/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * @deprecated Kept for backwards compatibility with v0.x.
 *
 * Any `SimpleUserElementWithWritableFlow` can be expressed as a
 * `SimpleElementWithWritableFlow`.
 * Please consider using `SimpleElementWithWritableFlow` for new code.
 */
abstract xhp class SimpleUserElementWithWritableFlow
  extends SimpleElementWithWritableFlow {
  use IgnoreSuccessorFlow;

  /**
   * Return your representation by composing something Streamable. You may not
   * call methods on the Flow after the method call completes.
   */
  abstract protected function compose(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\WritableFlow>
      $descendant_flow,
  ): SGMLStreamInterfaces\Streamable;

  final protected function render(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\WritableFlow>
      $descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  ): SGMLStreamInterfaces\Streamable {
    return $this->compose($descendant_flow);
  }
}
