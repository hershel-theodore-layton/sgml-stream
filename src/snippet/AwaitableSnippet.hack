namespace HTL\SGMLStream;

use namespace HH\Asio;
use namespace HTL\SGMLStreamInterfaces;

/**
 * Primes the snippets from the $impl as soon as it resolves. Will notify the
 * Consumer during feedBytesToConsumerAsync if the Awaitable has not resolved
 * when feedBytesToConsumerAsync is called.
 */
final class AwaitableSnippet implements SGMLStreamInterfaces\Snippet {
  private ?Awaitable<vec<SGMLStreamInterfaces\Snippet>> $snippetsAwaitable;

  public function __construct(
    private (function(
      SGMLStreamInterfaces\CopyableFlow,
    ): Awaitable<SGMLStreamInterfaces\SnippetStream>) $childFunc,
  ) {}

  public async function primeAsync(
    SGMLStreamInterfaces\CopyableFlow $flow,
  ): Awaitable<void> {
    $this->snippetsAwaitable = async {
      $stream = await ($this->childFunc)($flow);
      return $stream->collect();
    };
    $snippets = await $this->snippetsAwaitable;

    $awaitables = vec[];
    foreach ($snippets as $snippet) {
      $awaitables[] = $snippet->primeAsync($flow);
    }

    await AwaitAllWaitHandle::fromVec($awaitables);
  }

  public async function feedBytesToConsumerAsync(
    SGMLStreamInterfaces\Consumer $consumer,
  ): Awaitable<void> {
    $snippets_awaitable = $this->snippetsAwaitable;
    invariant(
      $snippets_awaitable is nonnull,
      '%s was not primed before',
      static::class,
    );
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
