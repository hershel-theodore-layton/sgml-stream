/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HH\Asio;
use namespace HTL\SGMLStreamInterfaces;

/**
 * Primes the snippets from the $impl as soon as it resolves. Will notify the
 * Consumer during feedBytesToConsumerAsync if the Awaitable has not resolved
 * when feedBytesToConsumerAsync is called.
 */
final class AwaitableSnippet implements SGMLStreamInterfaces\Snippet {
  private ?Awaitable<(vec<SGMLStreamInterfaces\Snippet>, Awaitable<mixed>)>
    $awaitable;
  private ?\Throwable $caughtThrowable;

  public function __construct(
    private (function(
      SGMLStreamInterfaces\CopyableFlow,
    ): Awaitable<SGMLStreamInterfaces\SnippetStream>) $childFunc,
  ) {}

  public async function primeAsync(
    SGMLStreamInterfaces\CopyableFlow $flow,
  ): Awaitable<void> {
    try {
      $this->awaitable = async {
        $stream = await ($this->childFunc)($flow);
        $snippets = $stream->collect();

        $awaitables = vec[];
        foreach ($snippets as $snippet) {
          $awaitables[] = $snippet->primeAsync($flow);
        }

        return tuple($snippets, AwaitAllWaitHandle::fromVec($awaitables));
      };
    } catch (\Throwable $t) {
      $this->caughtThrowable = $t;
      return;
    }

    list($_, $prime_async_of_children) = await $this->awaitable;
    await $prime_async_of_children;
  }

  public async function feedBytesToConsumerAsync(
    SGMLStreamInterfaces\Consumer $consumer,
  ): Awaitable<void> {
    $snippets_awaitable = async {
      $this->awaitable;
      if ($this->awaitable is null) {
        throw $this->caughtThrowable ??
          new _Private\SnippetNotPrimedException(static::class);
      }
      list($snippets, $_) = await $this->awaitable;
      return $snippets;
    };
    if (!Asio\has_finished($snippets_awaitable)) {
      concurrent {
        await $consumer->receiveWaitNotificationAsync();
        $snippets = await $snippets_awaitable;
      }
    } else {
      $snippets = Asio\result($snippets_awaitable);
    }

    foreach ($snippets as $snippet) {
      /* HHAST_IGNORE_ERROR[DontAwaitInALoop]
       * All these awaitables were started in `primeAsync()`,
       * so no false dependencies are constructed.
       * We just MUST collect bytes in order. */
      await $snippet->feedBytesToConsumerAsync($consumer);
    }
  }
}
