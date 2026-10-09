/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\{SGMLStream, SGMLStreamInterfaces, TestChain};
use type Exception;
use function HTL\Expect\expect;

<<TestChain\Discover>>
function snippet_priming_failure_test(
  TestChain\Chain $chain,
)[]: TestChain\Chain {
  $group = $chain->group(__FUNCTION__);
  foreach (vec[false, true] as $single_use) {
    foreach (vec['root', 'composable', 'awaitable', 'successor'] as $wrapper) {
      foreach (vec[false, true] as $delayed) {
        $group = $group->testAsync(
          ($single_use ? 'single_use' : 'reusable').
          '_'.
          $wrapper.
          ($delayed ? '_delayed' : '_immediate'),
          async ()[defaults] ==> {
            $failure = new Exception('prime failed');
            $snippet = new PrimingTestSnippet('success', $delayed, $failure);
            $consumer = new ConcatenationRecordingConsumer();
            $caught = null;
            try {
              await render_priming_test_async(
                vec[$snippet],
                $wrapper,
                $single_use,
                $consumer,
              );
            } catch (Exception $e) {
              $caught = $e;
            }
            expect($caught === $failure)->toEqual(true);
            expect($consumer->events)->toEqual(vec['bytes:success']);
          },
        );
      }
      $group = $group->testAsync(
        ($single_use ? 'single_use' : 'reusable').
        '_'.
        $wrapper.
        '_streams_while_priming',
        async ()[defaults] ==> {
          $first = new PrimingTestSnippet('first', true, null);
          $second = new PrimingTestSnippet('second', true, null);
          $consumer = new ConcatenationRecordingConsumer();
          await render_priming_test_async(
            vec[$first, $second],
            $wrapper,
            $single_use,
            $consumer,
          );
          expect($first->fedWhilePriming)->toEqual(true);
          expect($second->fedWhilePriming)->toEqual(true);
          expect($consumer->events)->toEqual(vec[
            'bytes:first',
            'bytes:second',
            'complete',
          ]);
        },
      );
    }
  }
  return $group;
}

async function render_priming_test_async(
  vec<SGMLStreamInterfaces\Snippet> $snippets,
  string $wrapper,
  bool $single_use,
  SGMLStreamInterfaces\Consumer $consumer,
)[defaults]: Awaitable<void> {
  $child_stream = new SGMLStream\ConcatenatingStream();
  foreach ($snippets as $snippet) {
    $child_stream->addSnippet($snippet);
  }
  $flow = SGMLStream\FirstComeFirstServedFlow::createEmpty();
  switch ($wrapper) {
    case 'root':
      $stream = $child_stream;
      break;
    case 'composable':
      $stream = new SGMLStream\ConcatenatingStream();
      $stream->addSnippet(new SGMLStream\ComposableSnippet(
        new PrimingTestSuccessorProcessor(),
        $descendant_flow ==> tuple($child_stream, $descendant_flow),
      ));
      break;
    case 'awaitable':
      $stream = new SGMLStream\ConcatenatingStream();
      $stream->addSnippet(new SGMLStream\AwaitableSnippet(
        new PrimingTestSuccessorProcessor(),
        async $descendant_flow ==> tuple($child_stream, $descendant_flow),
      ));
      break;
    case 'successor':
      $stream = new SGMLStream\ConcatenatingStream();
      $stream->addSnippet(new SGMLStream\AwaitableSnippetWithSuccessorFlow(
        async ($descendant_flow, $_successor_flow) ==>
          tuple($child_stream, $descendant_flow),
      ));
      break;
    default:
      invariant_violation('Unknown wrapper: %s', $wrapper);
  }
  if ($single_use) {
    await (new SGMLStream\ConcurrentSingleUseRenderer($stream))
      ->renderAsync($consumer, $flow);
  } else {
    await (new SGMLStream\ConcurrentReusableRenderer())->renderAsync(
      $stream,
      new PrimingTestEmptyStreamable(),
      $consumer,
      $flow,
      $flow,
      SGMLStream\FirstComeFirstServedFlow::createEmpty(),
    );
  }
}

final class PrimingTestSnippet implements SGMLStreamInterfaces\Snippet {
  private bool $primingFinished = false;
  public bool $fedWhilePriming = false;

  public function __construct(
    private string $bytes,
    private bool $delayed,
    private ?Exception $failure,
  )[] {}

  public async function primeAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\CopyableFlow> $_flow,
  )[defaults]: Awaitable<void> {
    if ($this->delayed) {
      await RescheduleWaitHandle::create(
        RescheduleWaitHandle::QUEUE_DEFAULT,
        0,
      );
    }
    $this->primingFinished = true;
    if ($this->failure is nonnull) {
      throw $this->failure;
    }
  }

  public async function feedBytesToConsumerAsync(
    SGMLStreamInterfaces\Consumer $consumer,
    SGMLStreamInterfaces\Successor<SGMLStreamInterfaces\WritableFlow>
      $_successor_flow,
  )[defaults]: Awaitable<void> {
    $this->fedWhilePriming = !$this->primingFinished;
    await $consumer->consumeAsync($this->bytes);
  }
}

final class PrimingTestSuccessorProcessor
  implements SGMLStreamInterfaces\CanProcessSuccessorFlow {
  use SGMLStream\IgnoreSuccessorFlow;
}

final class PrimingTestEmptyStreamable
  implements SGMLStreamInterfaces\Streamable {
  public function placeIntoSnippetStream(
    SGMLStreamInterfaces\SnippetStream $_stream,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  )[defaults]: void {}
}
