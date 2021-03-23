namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * Primes the snippets from $childFunc before awaiting anything.
 */
final class ComposableSnippet implements SGMLStreamInterfaces\Snippet {
  private ?vec<SGMLStreamInterfaces\Snippet> $snippets;

  public function __construct(
    private (function(
      SGMLStreamInterfaces\CopyableFlow,
    ): SGMLStreamInterfaces\SnippetStream) $childFunc,
  ) {}

  public async function primeAsync(
    SGMLStreamInterfaces\CopyableFlow $flow,
  ): Awaitable<void> {
    $this->snippets = ($this->childFunc)($flow)->collect();

    $awaitables = vec[];
    foreach ($this->snippets as $snippet) {
      $awaitables[] = $snippet->primeAsync($flow);
    }

    await AwaitAllWaitHandle::fromVec($awaitables);
  }

  public async function feedBytesToConsumerAsync(
    SGMLStreamInterfaces\Consumer $consumer,
  ): Awaitable<void> {
    invariant(
      $this->snippets is nonnull,
      '%s was not primed before',
      static::class,
    );

    foreach ($this->snippets as $snippet) {
      /* HHAST_IGNORE_ERROR[DontAwaitInALoop]
       * All these awaitables were started in `primeAsync()`,
       * so no false dependencies are constructed.
       * We just MUST collect bytes in order. */
      await $snippet->feedBytesToConsumerAsync($consumer);
    }
  }
}
