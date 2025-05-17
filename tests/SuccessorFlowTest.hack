/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HH\Asio;
use namespace HH\Lib\Vec;
use namespace HTL\{SGMLStream, SGMLStreamInterfaces};
use function HTL\Expect\{expect, expect_invoked};
use function clock_gettime_ns;
use const CLOCK_MONOTONIC;

use type Facebook\HackTest\HackTest;

final class SuccessorFlowTest extends HackTest {
  public async function testSuccessorFlowWritesAppearInDocumentOrderAndFlowIsNotCopied(
  )[defaults]: Awaitable<void> {
    $successor_flow =
      SGMLStream\ExclamationConstFlow::createWithConstantsAndVariables(
        dict['!mutable_vec' => new MutableVecOfInt(vec[])],
        dict[],
      );
    $streamable =
      <Immediate number={1}>
        <Immediate number={2}><Immediate number={3}></Immediate></Immediate>
        <Slow number={4}><Immediate number={5}></Immediate></Slow>
        <Immediate number={6}><Immediate number={7}></Immediate></Immediate>
      </Immediate>;

    await static::renderAsync($streamable, $successor_flow);

    expect($successor_flow->getx('!mutable_vec') as MutableVecOfInt->value)
      ->toEqual(Vec\range(1, 7));

    // We did indeed stall some time for the following Immediates.
    expect($successor_flow->getx('Asio\\usleep(42)') as int)->toBeGreaterThan(
      41000,
    );

    $successor_flow->assignVariable('a', 'b');
    $successor_flow->makeCopyForChild();
    // And only now it is copied.
    expect_invoked(() ==> $successor_flow->assignVariable('b', 'c'))
      ->toHaveThrown<InvariantException>();
  }

  public async function testCanOnlyObservePredecessorData(
  )[defaults]: Awaitable<void> {
    $successor_flow =
      SGMLStream\ExclamationConstFlow::createWithConstantsAndVariables(
        dict['!mutable_vec' => new MutableVecOfInt(vec[])],
        dict[],
      );
    $streamable =
      <Immediate number={1}>
        <Slow number={2} />
        <Immediate number={3} />
        <DumpMutableVecOfInt />
        <Immediate number={4} />
        <Slow number={5} />
        <Immediate number={6} />
        <DumpMutableVecOfInt />
      </Immediate>;

    $result = await static::renderAsync($streamable, $successor_flow);

    $expected = '<element data-wrote="1"><element data-wrote="2"></element>'.
      '<element data-wrote="3"></element><element>123</element>'.
      // notice                                   ^^^
      '<element data-wrote="4"></element><element data-wrote="5"></element>'.
      '<element data-wrote="6"></element><element>123456</element></element>';
    // notice                                     ^^^^^^

    expect($result)->toEqual($expected);
  }

  private static async function renderAsync(
    SGMLStreamInterfaces\Streamable $streamable,
    SGMLStreamInterfaces\Successor<SGMLStreamInterfaces\WritableFlow> $flow,
  )[defaults]: Awaitable<string> {
    $consumer = new SGMLStream\ToStringConsumer();
    $renderer = new SGMLStream\ConcurrentReusableRenderer();
    await $renderer->renderAsync(
      new SGMLStream\ConcatenatingStream(),
      $streamable,
      $consumer,
      SGMLStream\FirstComeFirstServedFlow::createEmpty(),
      SGMLStream\FirstComeFirstServedFlow::createEmpty(),
      $flow,
    );
    return $consumer->toString();
  }
}

final class Immediate extends SGMLStream\SimpleElement {
  attribute int number @required;

  <<__Override>>
  public function processSuccessorFlow(
    SGMLStreamInterfaces\Successor<SGMLStreamInterfaces\WritableFlow> $flow,
  )[defaults]: void {
    $flow->declareConstant(
      '!'.$this->:number,
      clock_gettime_ns(CLOCK_MONOTONIC),
    );
    $flow->getx('!mutable_vec') as MutableVecOfInt->value[] = $this->:number;
  }

  <<__Override>>
  protected function render(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\Flow>
      $_descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  )[]: SGMLStreamInterfaces\Streamable {
    return
      <element data-wrote={$this->:number}>{$this->getChildren()}</element>;
  }
}

final class Slow extends SGMLStream\AsynchronousElement {
  attribute int number @required;

  use SGMLStream\CallbackSuccessorFlow;

  <<__Override>>
  protected async function renderAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\Flow>
      $_descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  )[defaults]: Awaitable<SGMLStreamInterfaces\Streamable> {
    $start = clock_gettime_ns(CLOCK_MONOTONIC);
    await Asio\usleep(42);
    $end = clock_gettime_ns(CLOCK_MONOTONIC);
    $this->setSuccessorFlowCallback(
      $sf ==> {
        $sf->getx('!mutable_vec') as MutableVecOfInt->value[] = $this->:number;
        $sf->declareConstant(
          '!'.$this->:number,
          clock_gettime_ns(CLOCK_MONOTONIC),
        );
        $sf->assignVariable('Asio\\usleep(42)', $end - $start);
      },
    );
    return
      <element data-wrote={$this->:number}>{$this->getChildren()}</element>;
  }
}

final class DumpMutableVecOfInt
  extends SGMLStream\AsynchronousElementWithSuccessorFlow {

  <<__Override>>
  protected async function composeAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\WritableFlow>
      $_descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
    SGMLStreamInterfaces\Successor<SGMLStreamInterfaces\WritableFlow>
      $successor_flow,
  )[]: Awaitable<SGMLStreamInterfaces\Streamable> {
    return
      <element>
        {$successor_flow->getx('!mutable_vec') as MutableVecOfInt->value}
      </element>;
  }
}
