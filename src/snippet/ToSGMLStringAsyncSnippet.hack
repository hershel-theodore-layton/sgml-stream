namespace HTL\SGMLStream;

use namespace HH\Asio;
use namespace HTL\SGMLStreamInterfaces;

/**
 * Used for wrapping Elements that don't implement
 * SGMLStreamInterfaces\Streamable and other subclasses of
 * SGMLStreamInterfaces\ToSGMLStringAsync. An empty string it optimized away and
 * will not call the consumeAsync method on the Renderer. If the content is not
 * yet ready, the Renderer is notified.
 */
final class ToSGMLStringAsyncSnippet implements SGMLStreamInterfaces\Snippet {
  private ?Awaitable<string> $stringAwaitable;
  public function __construct(
    private SGMLStreamInterfaces\ToSGMLStringAsync $toSGMLStringAsync,
  ) {}

  public async function primeAsync(
    SGMLStreamInterfaces\CopyableFlow $_flow,
  ): Awaitable<void> {
    $this->stringAwaitable = $this->toSGMLStringAsync->toHTMLStringAsync();
    await $this->stringAwaitable;
  }

  public async function feedBytesToConsumerAsync(
    SGMLStreamInterfaces\Consumer $consumer,
  ): Awaitable<void> {
    $string_awaitable = $this->stringAwaitable;
    invariant(
      $string_awaitable is nonnull,
      '%s was not primed before',
      static::class,
    );
    if (!Asio\has_finished($string_awaitable)) {
      concurrent {
        await $consumer->receiveWaitNotificationAsync();
        $string = await $string_awaitable;
      }
    } else {
      $string = Asio\result($string_awaitable);
    }

    if ($string !== '') {
      await $consumer->consumeAsync($string);
    }
  }
}
