namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * Consumes content by appending to a StringBuilder. This string can be
 * retrieved via toString() after the render is complete. This consumer
 * does not support streaming multiple documents in series.
 */
final class ToStringConsumer implements SGMLStreamInterfaces\Consumer {
  private string $buf = '';
  private bool $isComplete = false;

  public async function consumeAsync(string $bytes): Awaitable<void> {
    $this->buf .= $bytes;
  }

  public async function receiveWaitNotificationAsync(): Awaitable<void> {}
  public async function flushAsync(): Awaitable<void> {}
  public async function theDocumentIsCompleteAsync(): Awaitable<void> {
    $this->isComplete = true;
  }

  public function toString(): string {
    invariant(
      $this->isComplete,
      'The Streamable has not yet been fully consumed. '.
      'The document is not complete yet.',
    );
    return $this->buf;
  }
}
