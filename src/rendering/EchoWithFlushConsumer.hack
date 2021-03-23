namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * Consumes content by using echo and flush().
 */
final class EchoWithFlushConsumer implements SGMLStreamInterfaces\Consumer {
  public async function consumeAsync(string $bytes): Awaitable<void> {
    echo $bytes;
  }
  public async function receiveWaitNotificationAsync(): Awaitable<void> {
    \flush();
  }
  public async function flushAsync(): Awaitable<void> {
    \flush();
  }
  public async function theDocumentIsCompleteAsync(): Awaitable<void> {
    \flush();
  }
}
