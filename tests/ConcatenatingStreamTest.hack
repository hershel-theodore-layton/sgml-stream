/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\{SGMLStream, SGMLStreamInterfaces, TestChain};
use function HTL\Expect\expect;
use function HTL\Pragma\pragma;
use function count;

<<TestChain\Discover>>
function concatenating_stream_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->test(
      'collect_omits_only_implicit_empty_snippets_and_resets',
      ()[defaults] ==> {
        $stream = new SGMLStream\ConcatenatingStream();
        expect($stream->collect())->toEqual(vec[]);

        $flush = new SGMLStream\FlushingSnippet();
        $empty = new SGMLStream\SGMLSnippet('');
        $null = SGMLStream\NullSnippet::instance();
        $stream->addSafeSGML('');
        $stream->addSnippet($flush);
        $stream->addSnippet($empty);
        $stream->addSnippet($null);
        expect($stream->collect())->toEqual(vec[$flush, $empty, $null]);
        expect($stream->collect())->toEqual(vec[]);

        $stream->addSafeSGML('reused');
        $collected = $stream->collect();
        expect(count($collected))->toEqual(1);
        expect($collected[0] is SGMLStream\SGMLSnippet)->toEqual(true);
        expect($stream->collect())->toEqual(vec[]);
      },
    )
    ->testAsync(
      'render_preserves_bytes_flushes_and_completion',
      async ()[defaults] ==> {
        $stream = new SGMLStream\ConcatenatingStream();
        $consumer = new ConcatenationRecordingConsumer();
        $renderer = new SGMLStream\ConcurrentReusableRenderer();
        foreach (vec[false, true] as $with_content) {
          pragma('PhaLinters', 'fixme:dont_await_in_a_loop');
          await $renderer->renderAsync(
            $stream,
            new ConcatenationStreamable($with_content),
            $consumer,
            SGMLStream\FirstComeFirstServedFlow::createEmpty(),
            SGMLStream\FirstComeFirstServedFlow::createEmpty(),
            SGMLStream\FirstComeFirstServedFlow::createEmpty(),
          );
        }
        expect($consumer->events)->toEqual(vec[
          'complete',
          'bytes:ab',
          'flush',
          'flush',
          'bytes:cd',
          'complete',
        ]);
      },
    );
}

final class ConcatenationStreamable implements SGMLStreamInterfaces\Streamable {
  public function __construct(private bool $withContent)[] {}

  public function placeIntoSnippetStream(
    SGMLStreamInterfaces\SnippetStream $stream,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  )[defaults]: void {
    if (!$this->withContent) {
      return;
    }
    $stream->addSafeSGML('a');
    $stream->addSafeSGML('b');
    $stream->addSnippet(new SGMLStream\FlushingSnippet());
    $stream->addSnippet(new SGMLStream\FlushingSnippet());
    $stream->addSafeSGML('c');
    $stream->addSafeSGML('d');
  }
}

final class ConcatenationRecordingConsumer
  implements SGMLStreamInterfaces\Consumer {
  public vec<string> $events = vec[];

  public async function consumeAsync(string $bytes)[defaults]: Awaitable<void> {
    $this->events[] = 'bytes:'.$bytes;
  }

  public async function flushAsync()[defaults]: Awaitable<void> {
    $this->events[] = 'flush';
  }

  public async function receiveWaitNotificationAsync(
  )[defaults]: Awaitable<void> {
    $this->events[] = 'wait';
  }

  public async function theDocumentIsCompleteAsync(
  )[defaults]: Awaitable<void> {
    $this->events[] = 'complete';
  }
}
