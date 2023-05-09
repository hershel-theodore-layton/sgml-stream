/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * A noop snippet.
 */
final class NullSnippet implements SGMLStreamInterfaces\Snippet {
  private static ?NullSnippet $instance;

  /**
   * Not a singleton, but a reusable object.
   * Constructing a new instance each time is also valid, just wasteful.
   */
  public static function instance(): this {
    if (self::$instance is null) {
      self::$instance = new self();
    }
    return self::$instance;
  }

  public async function primeAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\Flow> $_flow,
  ): Awaitable<void> {}

  public async function feedBytesToConsumerAsync(
    SGMLStreamInterfaces\Consumer $_consumer,
    SGMLStreamInterfaces\Successor<SGMLStreamInterfaces\WritableFlow>
      $_successor_flow,
  ): Awaitable<void> {}
}
