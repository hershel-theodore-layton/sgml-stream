/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * A noop snippet.
 */
final class NullSnippet implements SGMLStreamInterfaces\Snippet {
  /**
   * Not a singleton, but a reusable object.
   * Constructing a new instance each time is also valid, just wasteful.
   */
  <<__Memoize>>
  public static function instance()[]: this {
    return new self();
  }

  public async function primeAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\Flow> $_flow,
  )[defaults]: Awaitable<void> {}

  public async function feedBytesToConsumerAsync(
    SGMLStreamInterfaces\Consumer $_consumer,
    SGMLStreamInterfaces\Successor<SGMLStreamInterfaces\WritableFlow>
      $_successor_flow,
  )[defaults]: Awaitable<void> {}
}
