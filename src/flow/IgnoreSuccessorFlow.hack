/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * Hooks the `processSuccessorFlow()` method with a noop.
 */
trait IgnoreSuccessorFlow {
  require implements SGMLStreamInterfaces\CanProcessSuccessorFlow;

  final public function processSuccessorFlow(
    SGMLStreamInterfaces\Successor<SGMLStreamInterfaces\WritableFlow>
      $_successor_flow,
  )[]: void {}
}
