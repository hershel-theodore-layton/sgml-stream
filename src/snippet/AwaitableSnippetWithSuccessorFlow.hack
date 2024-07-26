/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HH\Asio;
use namespace HTL\SGMLStreamInterfaces;
use function HTL\Pragma\pragma;

/**
 * Priming does nothing. Waits until feedBytesToConsumer to invoke childFunc.
 * This gives the ordering guarantee for successor flow.
 */
final class AwaitableSnippetWithSuccessorFlow
  implements SGMLStreamInterfaces\Snippet {
  private ?SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\CopyableFlow>
    $descendantFlow;

  public function __construct(
    private (function(
      SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\CopyableFlow>,
      SGMLStreamInterfaces\Successor<SGMLStreamInterfaces\WritableFlow>,
    )[defaults]: Awaitable<(
      SGMLStreamInterfaces\SnippetStream,
      SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\CopyableFlow>,
    )>) $childFunc,
  )[] {}

  public async function primeAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\CopyableFlow> $flow,
  )[defaults]: Awaitable<void> {
    $this->descendantFlow = $flow;
  }

  public async function feedBytesToConsumerAsync(
    SGMLStreamInterfaces\Consumer $consumer,
    SGMLStreamInterfaces\Successor<SGMLStreamInterfaces\WritableFlow>
      $successor_flow,
  )[defaults]: Awaitable<void> {
    $descendant_flow = $this->descendantFlow;

    if ($descendant_flow is null) {
      throw new _Private\SnippetNotPrimedException(static::class);
    }

    $awaitable = ($this->childFunc)($descendant_flow, $successor_flow);

    // We can't start the childFunc earlier, because of the successor flow.
    // This awaitable was started on the line above. So if there is any IO
    // the true branch is taken.
    if (!Asio\has_finished($awaitable)) {
      concurrent {
        await $consumer->receiveWaitNotificationAsync();
        list($stream, $descendant_flow) = await $awaitable;
      }
    } else {
      list($stream, $descendant_flow) = Asio\result($awaitable);
    }

    $snippets = $stream->collect();

    $awaitables = vec[];
    foreach ($snippets as $snippet) {
      $awaitables[] = $snippet->primeAsync($descendant_flow);
    }

    concurrent {
      await AwaitAllWaitHandle::fromVec($awaitables);
      await async {
        foreach ($snippets as $snippet) {
          /* feedBytesToConsumer operates on the awaitables from the race.
           * There are no false dependencies here.
           * We just MUST collect bytes in order. */
          pragma('PhaLinters', 'fixme:dont_await_in_a_loop');
          await $snippet->feedBytesToConsumerAsync($consumer, $successor_flow);
        }
      };
    }
  }
}
