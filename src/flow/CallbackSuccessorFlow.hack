/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * Hooks the `processSuccessorFlow()` method with a call to your callback.
 * Set the callback using `setSuccessorFlowCallback()`.
 * Your callback will be invoked after your render method completes and right
 * before your first byte of output is sent to the Consumer.
 * You will not be able to use the variables and constants from the successor
 * flow in your render method.
 *
 * You may only set a single callback.
 * If you need to set multiple callbacks, you should hook `processSuccessorFlow`
 * some other way.
 */
trait CallbackSuccessorFlow {
  require implements SGMLStreamInterfaces\CanProcessSuccessorFlow;

  private ?(function(
    SGMLStreamInterfaces\Successor<SGMLStreamInterfaces\WritableFlow>,
  )[defaults]: void) $callback;

  final protected function setSuccessorFlowCallback(
    (function(
      SGMLStreamInterfaces\Successor<SGMLStreamInterfaces\WritableFlow>,
    ): void) $callback,
  )[write_props]: void {
    invariant($this->callback is null, 'You may not set multiple callbacks.');
    $this->callback = $callback;
  }

  final public function processSuccessorFlow(
    SGMLStreamInterfaces\Successor<SGMLStreamInterfaces\WritableFlow>
      $successor_flow,
  )[defaults]: void {
    if ($this->callback is nonnull) {
      ($this->callback)($successor_flow);
    }
  }
}
