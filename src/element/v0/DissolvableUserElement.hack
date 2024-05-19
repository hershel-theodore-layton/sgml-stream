/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * @deprecated Kept for backwards compatibility with v0.x.
 *
 * Any `DissolvableUserElement` can be expressed as a `DissolvableElement`.
 * Please consider using `DissolvableElement` for new code.
 */
abstract xhp class DissolvableUserElement extends DissolvableElement {
  /**
   * Return your representation by composing something Streamable.
   * Do it quickly, as this work happens before the async machine is started.
   */
  abstract protected function compose(
  )[defaults]: SGMLStreamInterfaces\Streamable;

  <<__Override>>
  final protected function render(
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_flow,
  )[defaults]: SGMLStreamInterfaces\Streamable {
    return $this->compose();
  }
}
