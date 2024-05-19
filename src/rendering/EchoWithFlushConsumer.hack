/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * Consumes content by using echo and flush().
 */
final class EchoWithFlushConsumer implements SGMLStreamInterfaces\Consumer {
  public async function consumeAsync(string $bytes)[defaults]: Awaitable<void> {
    echo $bytes;
  }
  public async function receiveWaitNotificationAsync(
  )[defaults]: Awaitable<void> {
    \flush();
  }
  public async function flushAsync()[defaults]: Awaitable<void> {
    \flush();
  }
  public async function theDocumentIsCompleteAsync(
  )[defaults]: Awaitable<void> {
    \flush();
  }
}
