namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * A noop snippet.
 */
final class NullSnippet implements SGMLStreamInterfaces\Snippet {
  public async function primeAsync(
    SGMLStreamInterfaces\Flow $_flow,
  ): Awaitable<void> {}

  public async function feedBytesToConsumerAsync(
    SGMLStreamInterfaces\Consumer $_consumer,
  ): Awaitable<void> {}
}
