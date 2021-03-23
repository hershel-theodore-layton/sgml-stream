namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * This renderer may only be used once.
 */
final class ConcurrentSingleUseRenderer
  implements SGMLStreamInterfaces\Renderer {
  private bool $hasRendered = false;

  public function __construct(
    private SGMLStreamInterfaces\SnippetStream $stream,
  ) {}

  public async function renderAsync(
    SGMLStreamInterfaces\Consumer $consumer,
    SGMLStreamInterfaces\CopyableFlow $flow,
  ): Awaitable<void> {
    invariant(
      !$this->hasRendered,
      'You may not use the same %s twice',
      static::class,
    );
    $this->hasRendered = true;

    $snippets = $this->stream->collect();

    $awaitables = vec[];
    foreach ($snippets as $snippet) {
      $awaitables[] = $snippet->primeAsync($flow);
    }

    concurrent {
      // Race them all,...
      await AwaitAllWaitHandle::fromVec($awaitables);
      await async {
        foreach ($snippets as $snippet) {
          /* HHAST_IGNORE_ERROR[DontAwaitInALoop]
           * feedBytesToConsumer operates on the awaitables from the race.
           * There are no false dependencies here.
           * We just MUST collect bytes in order. */
          await $snippet->feedBytesToConsumerAsync($consumer);
        }
      };
    }

    await $consumer->theDocumentIsCompleteAsync();
  }
}
