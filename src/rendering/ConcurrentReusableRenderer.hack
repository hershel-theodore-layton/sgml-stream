/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

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
  ): Awaitable<void> {
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
          /* HHAST_IGNORE_ERROR[DontAwaitInALoop]
           * feedBytesToConsumer operates on the awaitables from the race.
           * There are no false dependencies here.
           * We just MUST collect bytes in order. */
          await $snippet->feedBytesToConsumerAsync($consumer, $successor_flow);
        }
      };
    }

    await $consumer->theDocumentIsCompleteAsync();
  }
}
