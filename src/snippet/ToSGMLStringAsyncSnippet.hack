/** sgml-stream is MIT licensed, see /LICENSE. */
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
  private ?\Throwable $caughtThrowable;

  public function __construct(
    private SGMLStreamInterfaces\ToSGMLStringAsync $toSGMLStringAsync,
  ) {}

  public async function primeAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\CopyableFlow> $_flow,
  ): Awaitable<void> {
    try {
      $this->stringAwaitable = $this->toSGMLStringAsync->toHTMLStringAsync();
      await $this->stringAwaitable;
    } catch (\Throwable $t) {
      $this->caughtThrowable = $t;
    }
  }

  public async function feedBytesToConsumerAsync(
    SGMLStreamInterfaces\Consumer $consumer,
    SGMLStreamInterfaces\Successor<SGMLStreamInterfaces\WritableFlow>
      $_successor_flow,
  ): Awaitable<void> {
    $string_awaitable = $this->stringAwaitable;
    if ($string_awaitable is null) {
      throw $this->caughtThrowable ??
        new _Private\SnippetNotPrimedException(static::class);
    }
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
