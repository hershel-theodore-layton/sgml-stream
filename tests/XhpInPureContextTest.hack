/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\{SGMLStream, SGMLStreamInterfaces, TestChain};
use type LogicException;
use function HTL\Expect\{expect, expect_invoked};

<<TestChain\Discover>>
function xhp_in_pure_context_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->test(
      'test_constructing_the_built_in_xhp_elements_in_a_pure_context',
      () ==> {
        try {
          $_ = <element />;
          $_ = <TestAsynchronousUserElement />;
          $_ = <TestSimpleUserElement />;
          $_ = <TestAsynchronousUserElementWithWritableFlow />;
          $_ = <TestSimpleUserElementWithWritableFlow />;
          $_ = <TestDissolvableUserElement />;
          $_ = <TestAsynchronousElement />;
          $_ = <TestDissolvableElement />;
          $_ = <TestAsynchronousElementWithSuccessorFlow />;
          $_ = <TestSimpleElement />;
          $_ = <TestAsynchronousElementWithWritableFlow />;
          $_ = <TestSimpleElementWithWritableFlow />;
        } catch (LogicException $_) {
          // This is not testing runtime behavior, but the typechecker behavior.
        }
      },
    )
    ->test('test_init_is_called_at_construction_time', () ==> {
      expect_invoked(() ==> <TestAsynchronousUserElement />)->toHaveThrown<
        LogicException,
      >('TestAsynchronousUserElement');
      expect_invoked(() ==> <TestSimpleUserElement />)->toHaveThrown<
        LogicException,
      >('TestSimpleUserElement');
      expect_invoked(() ==> <TestAsynchronousUserElementWithWritableFlow />)
        ->toHaveThrown<LogicException>(
          'TestAsynchronousUserElementWithWritableFlow',
        );
      expect_invoked(() ==> <TestSimpleUserElementWithWritableFlow />)
        ->toHaveThrown<LogicException>('TestSimpleUserElementWithWritableFlow');
      expect_invoked(() ==> <TestDissolvableUserElement />)->toHaveThrown<
        LogicException,
      >('TestDissolvableUserElement');
      expect_invoked(() ==> <TestAsynchronousElement />)->toHaveThrown<
        LogicException,
      >('TestAsynchronousElement');
      expect_invoked(() ==> <TestDissolvableElement />)->toHaveThrown<
        LogicException,
      >('TestDissolvableElement');
      expect_invoked(() ==> <TestAsynchronousElementWithSuccessorFlow />)
        ->toHaveThrown<LogicException>(

          'TestAsynchronousElementWithSuccessorFlow',
        );
      expect_invoked(() ==> <TestSimpleElement />)->toHaveThrown<
        LogicException,
      >(

        'TestSimpleElement',
      );
      expect_invoked(() ==> <TestAsynchronousElementWithWritableFlow />)
        ->toHaveThrown<LogicException>(

          'TestAsynchronousElementWithWritableFlow',
        );
      expect_invoked(() ==> <TestSimpleElementWithWritableFlow />)
        ->toHaveThrown<LogicException>('TestSimpleElementWithWritableFlow');
    })
    ->testAsync(
      'test_can_still_use_an_impure_init_if_need_be_async',
      async ()[defaults] ==> {
        expect(await (<TestElementWithImpureInit />)->toHTMLStringAsync())
          ->toEqual('pass');
      },
    );
}

final class TestAsynchronousUserElement
  extends SGMLStream\AsynchronousUserElement {

  <<__Override>>
  public function init()[]: void {
    throw new LogicException((string)static::class);
  }

  <<__Override>>
  protected async function composeAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\Flow>
      $_descendant_flow,
  )[]: Awaitable<SGMLStreamInterfaces\Streamable> {
    return <element />;
  }
}

final class TestSimpleUserElement extends SGMLStream\SimpleUserElement {

  <<__Override>>
  public function init()[]: void {
    throw new LogicException((string)static::class);
  }

  <<__Override>>
  protected function compose(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\Flow>
      $_descendant_flow,
  )[]: SGMLStreamInterfaces\Streamable {
    return <element />;
  }
}

final class TestAsynchronousUserElementWithWritableFlow
  extends SGMLStream\AsynchronousUserElementWithWritableFlow {

  <<__Override>>
  public function init()[]: void {
    throw new LogicException((string)static::class);
  }

  <<__Override>>
  protected async function composeAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\WritableFlow>
      $_descendant_flow,
  )[]: Awaitable<SGMLStreamInterfaces\Streamable> {
    return <element />;
  }
}

final class TestSimpleUserElementWithWritableFlow
  extends SGMLStream\SimpleUserElementWithWritableFlow {

  <<__Override>>
  public function init()[]: void {
    throw new LogicException((string)static::class);
  }

  <<__Override>>
  protected function compose(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\WritableFlow>
      $_descendant_flow,
  )[]: SGMLStreamInterfaces\Streamable {
    return <element />;
  }
}

final class TestDissolvableUserElement
  extends SGMLStream\DissolvableUserElement {

  <<__Override>>
  public function init()[]: void {
    throw new LogicException((string)static::class);
  }

  <<__Override>>
  protected function compose()[]: SGMLStreamInterfaces\Streamable {
    return <element />;
  }
}

final class TestAsynchronousElement extends SGMLStream\AsynchronousElement {
  use SGMLStream\IgnoreSuccessorFlow;

  <<__Override>>
  public function init()[]: void {
    throw new LogicException((string)static::class);
  }

  <<__Override>>
  protected async function renderAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\Flow>
      $_descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  )[]: Awaitable<SGMLStreamInterfaces\Streamable> {
    return <element />;
  }
}

final class TestDissolvableElement extends SGMLStream\DissolvableElement {

  <<__Override>>
  public function init()[]: void {
    throw new LogicException((string)static::class);
  }

  <<__Override>>
  protected function render(
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  )[]: SGMLStreamInterfaces\Streamable {
    return <element />;
  }
}

final class TestAsynchronousElementWithSuccessorFlow
  extends SGMLStream\AsynchronousElementWithSuccessorFlow {

  <<__Override>>
  public function init()[]: void {
    throw new LogicException((string)static::class);
  }

  <<__Override>>
  protected async function composeAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\WritableFlow>
      $_descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
    SGMLStreamInterfaces\Successor<SGMLStreamInterfaces\WritableFlow>
      $_successor_flow,
  )[]: Awaitable<SGMLStreamInterfaces\Streamable> {
    return <element />;
  }
}

final class TestSimpleElement extends SGMLStream\SimpleElement {
  use SGMLStream\IgnoreSuccessorFlow;

  <<__Override>>
  public function init()[]: void {
    throw new LogicException((string)static::class);
  }

  <<__Override>>
  protected function render(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\Flow>
      $_descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  )[]: SGMLStreamInterfaces\Streamable {
    return <element />;
  }
}

final class TestAsynchronousElementWithWritableFlow
  extends SGMLStream\AsynchronousElementWithWritableFlow {
  use SGMLStream\IgnoreSuccessorFlow;

  <<__Override>>
  public function init()[]: void {
    throw new LogicException((string)static::class);
  }

  <<__Override>>
  protected async function renderAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\WritableFlow>
      $_descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  )[]: Awaitable<SGMLStreamInterfaces\Streamable> {
    return <element />;
  }
}

final class TestSimpleElementWithWritableFlow
  extends SGMLStream\SimpleElementWithWritableFlow {
  use SGMLStream\IgnoreSuccessorFlow;

  <<__Override>>
  public function init()[]: void {
    throw new LogicException((string)static::class);
  }

  <<__Override>>
  protected function render(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\WritableFlow>
      $_descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  )[]: SGMLStreamInterfaces\Streamable {
    return <element />;
  }
}

final class TestElementWithImpureInit extends SGMLStream\RootElement {
  const ctx INITIALIZATION_CTX = [defaults];

  private bool $canStillDoImpureThings = false;

  <<__Override>>
  protected function init()[defaults]: void {
    $this->canStillDoImpureThings = true;
  }

  <<__Override>>
  public function placeIntoSnippetStream(
    SGMLStreamInterfaces\SnippetStream $stream,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  )[write_props]: void {
    $stream->addSafeSGML($this->canStillDoImpureThings ? 'pass' : 'fail');
  }
}
