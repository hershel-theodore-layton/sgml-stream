/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;
use function HTL\Pragma\pragma;

/**
 * Primes the snippets from $childFunc before awaiting anything.
 */
final class ComposableSnippet implements SGMLStreamInterfaces\Snippet {
  private ?vec<SGMLStreamInterfaces\Snippet> $snippets;
  private ?\Throwable $caughtThrowable;

  public function __construct(
    private SGMLStreamInterfaces\CanProcessSuccessorFlow $processSuccessorFlow,
    private (function(
      SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\CopyableFlow>,
    ): (
      SGMLStreamInterfaces\SnippetStream,
      SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\CopyableFlow>,
    )) $childFunc,
  )[] {}

  public async function primeAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\CopyableFlow> $flow,
  )[defaults]: Awaitable<void> {
    try {
      list($stream, $flow) = ($this->childFunc)($flow);
      $this->snippets = $stream->collect();
    } catch (\Throwable $t) {
      $this->caughtThrowable = $t;
      return;
    }

    $awaitables = vec[];
    foreach ($this->snippets as $snippet) {
      $awaitables[] = $snippet->primeAsync($flow);
    }

    await AwaitAllWaitHandle::fromVec($awaitables);
  }

  public async function feedBytesToConsumerAsync(
    SGMLStreamInterfaces\Consumer $consumer,
    SGMLStreamInterfaces\Successor<SGMLStreamInterfaces\WritableFlow>
      $successor_flow,
  )[defaults]: Awaitable<void> {
    if ($this->snippets is null) {
      throw $this->caughtThrowable ??
        new _Private\SnippetNotPrimedException(static::class);
    }
    $snippets = $this->snippets;

    $this->processSuccessorFlow->processSuccessorFlow($successor_flow);

    foreach ($snippets as $snippet) {
      /* feedBytesToConsumer operates on the awaitables from the race.
       * There are no false dependencies here.
       * We just MUST collect bytes in order. */
      pragma('PhaLinters', 'fixme:dont_await_in_a_loop');
      await $snippet->feedBytesToConsumerAsync($consumer, $successor_flow);
    }
  }
}
