/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * Requests a Flush from the Consumer passed to it in feedBytesToConsumerAsync.
 */
final class FlushingSnippet implements SGMLStreamInterfaces\Snippet {
  public async function primeAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\Flow> $_flow,
  ): Awaitable<void> {}

  public async function feedBytesToConsumerAsync(
    SGMLStreamInterfaces\Consumer $consumer,
    SGMLStreamInterfaces\Successor<SGMLStreamInterfaces\WritableFlow>
      $_successor_flow,
  ): Awaitable<void> {
    await $consumer->flushAsync();
  }
}
