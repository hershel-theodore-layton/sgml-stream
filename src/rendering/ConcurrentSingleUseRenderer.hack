/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;
use function HTL\Pragma\pragma;

/**
 * @deprecated Use `ConcurrentReusableRenderer` instead.
 */
final class ConcurrentSingleUseRenderer
  implements SGMLStreamInterfaces\Renderer {
  private bool $hasRendered = false;

  public function __construct(
    private SGMLStreamInterfaces\SnippetStream $stream,
  )[] {}

  public async function renderAsync(
    SGMLStreamInterfaces\Consumer $consumer,
    SGMLStreamInterfaces\CopyableFlow $flow,
  )[defaults]: Awaitable<void> {
    invariant(
      !$this->hasRendered,
      'You may not use the same %s twice',
      static::class,
    );
    $descendant_flow =
      SGMLStreamInterfaces\cast_to_chameleon__DO_NOT_USE($flow);
    $successor_flow = FirstComeFirstServedFlow::createEmpty();
    $this->hasRendered = true;

    $snippets = $this->stream->collect();

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
