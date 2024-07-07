/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;
use function HTL\Pragma\pragma;

final class ConcurrentReusableRenderer
  implements SGMLStreamInterfaces\ReusableRenderer {
  public async function renderAsync(
    SGMLStreamInterfaces\SnippetStream $stream,
    SGMLStreamInterfaces\Streamable $streamable,
    SGMLStreamInterfaces\Consumer $consumer,
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\CopyableFlow>
      $descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $init_flow,
    SGMLStreamInterfaces\Successor<SGMLStreamInterfaces\WritableFlow>
      $successor_flow,
  )[defaults]: Awaitable<void> {
    $streamable->placeIntoSnippetStream($stream, $init_flow);
    $snippets = $stream->collect();

    $awaitables = vec[];
    foreach ($snippets as $snippet) {
      $awaitables[] = $snippet->primeAsync($descendant_flow);
    }

    concurrent {
      // Race them all,...
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

    await $consumer->theDocumentIsCompleteAsync();
  }
}
