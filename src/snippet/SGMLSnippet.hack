/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * Turn a plain string into a Snippet. The content is NOT escaped.
 */
final class SGMLSnippet implements SGMLStreamInterfaces\Snippet {
  /**
   * Callers of the constructor make the semantic promise that safeSGML is safe
   * to use in SGML contexts as the child of a node.
   * ```
   * <html>__HERE__</html>
   * ```
   * An empty string is optimized away and will not call the consumeAsync method
   * on the Renderer.
   */
  public function __construct(private string $safeSGML) {}

  public async function primeAsync(
    SGMLStreamInterfaces\Flow $_flow,
  ): Awaitable<void> {}

  public async function feedBytesToConsumerAsync(
    SGMLStreamInterfaces\Consumer $consumer,
  ): Awaitable<void> {
    if ($this->safeSGML !== '') {
      await $consumer->consumeAsync($this->safeSGML);
    }
  }
}
