/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use function Facebook\FBExpect\expect;
use type Facebook\HackTest\HackTest;
use namespace HTL\{SGMLStream, SGMLStreamInterfaces};
use type LogicException;

final class XhpInPureContextTest extends HackTest {
  public function test_constructing_the_built_in_xhp_elements_in_a_pure_context(
  )[]: void {
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
  }

  public function test_init_is_called_at_construction_time(): void {
    expect(() ==> <TestAsynchronousUserElement />)->toThrow(
      LogicException::class,
      'TestAsynchronousUserElement',
    );
    expect(() ==> <TestSimpleUserElement />)->toThrow(
      LogicException::class,
      'TestSimpleUserElement',
    );
    expect(() ==> <TestAsynchronousUserElementWithWritableFlow />)->toThrow(
      LogicException::class,
      'TestAsynchronousUserElementWithWritableFlow',
    );
    expect(() ==> <TestSimpleUserElementWithWritableFlow />)->toThrow(
      LogicException::class,
      'TestSimpleUserElementWithWritableFlow',
    );
    expect(() ==> <TestDissolvableUserElement />)->toThrow(
      LogicException::class,
      'TestDissolvableUserElement',
    );
    expect(() ==> <TestAsynchronousElement />)->toThrow(
      LogicException::class,
      'TestAsynchronousElement',
    );
    expect(() ==> <TestDissolvableElement />)->toThrow(
      LogicException::class,
      'TestDissolvableElement',
    );
    expect(() ==> <TestAsynchronousElementWithSuccessorFlow />)->toThrow(
      LogicException::class,
      'TestAsynchronousElementWithSuccessorFlow',
    );
    expect(() ==> <TestSimpleElement />)->toThrow(
      LogicException::class,
      'TestSimpleElement',
    );
    expect(() ==> <TestAsynchronousElementWithWritableFlow />)->toThrow(
      LogicException::class,
      'TestAsynchronousElementWithWritableFlow',
    );
    expect(() ==> <TestSimpleElementWithWritableFlow />)->toThrow(
      LogicException::class,
      'TestSimpleElementWithWritableFlow',
    );
  }

  public async function test_can_still_use_an_impure_init_if_need_be_async(
  ): Awaitable<void> {
    expect(await (<TestElementWithImpureInit />)->toHTMLStringAsync())->toEqual(
      'pass',
    );
  }
}

final class TestAsynchronousUserElement
  extends SGMLStream\AsynchronousUserElement {

  <<__Override>>
  public function init()[]: void {
    throw new LogicException(static::class);
  }

  <<__Override>>
  protected async function composeAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\Flow> $_descendant_flow,
  ): Awaitable<SGMLStreamInterfaces\Streamable> {
    return <element />;
  }
}

final class TestSimpleUserElement extends SGMLStream\SimpleUserElement {

  <<__Override>>
  public function init()[]: void {
    throw new LogicException(static::class);
  }

  <<__Override>>
  protected function compose(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\Flow> $_descendant_flow,
  ): SGMLStreamInterfaces\Streamable {
    return <element />;
  }
}

final class TestAsynchronousUserElementWithWritableFlow
  extends SGMLStream\AsynchronousUserElementWithWritableFlow {

  <<__Override>>
  public function init()[]: void {
    throw new LogicException(static::class);
  }

  <<__Override>>
  protected async function composeAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\WritableFlow>
      $_descendant_flow,
  ): Awaitable<SGMLStreamInterfaces\Streamable> {
    return <element />;
  }
}

final class TestSimpleUserElementWithWritableFlow
  extends SGMLStream\SimpleUserElementWithWritableFlow {

  <<__Override>>
  public function init()[]: void {
    throw new LogicException(static::class);
  }

  <<__Override>>
  protected function compose(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\WritableFlow>
      $_descendant_flow,
  ): SGMLStreamInterfaces\Streamable {
    return <element />;
  }
}

final class TestDissolvableUserElement
  extends SGMLStream\DissolvableUserElement {

  <<__Override>>
  public function init()[]: void {
    throw new LogicException(static::class);
  }

  <<__Override>>
  protected function compose(): SGMLStreamInterfaces\Streamable {
    return <element />;
  }
}

final class TestAsynchronousElement extends SGMLStream\AsynchronousElement {
  use SGMLStream\IgnoreSuccessorFlow;

  <<__Override>>
  public function init()[]: void {
    throw new LogicException(static::class);
  }

  <<__Override>>
  protected async function renderAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\Flow> $_descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  ): Awaitable<SGMLStreamInterfaces\Streamable> {
    return <element />;
  }
}

final class TestDissolvableElement extends SGMLStream\DissolvableElement {

  <<__Override>>
  public function init()[]: void {
    throw new LogicException(static::class);
  }

  <<__Override>>
  protected function render(
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  ): SGMLStreamInterfaces\Streamable {
    return <element />;
  }
}

final class TestAsynchronousElementWithSuccessorFlow
  extends SGMLStream\AsynchronousElementWithSuccessorFlow {

  <<__Override>>
  public function init()[]: void {
    throw new LogicException(static::class);
  }

  <<__Override>>
  protected async function composeAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\WritableFlow>
      $_descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
    SGMLStreamInterfaces\Successor<SGMLStreamInterfaces\WritableFlow>
      $_successor_flow,
  ): Awaitable<SGMLStreamInterfaces\Streamable> {
    return <element />;
  }
}

final class TestSimpleElement extends SGMLStream\SimpleElement {
  use SGMLStream\IgnoreSuccessorFlow;

  <<__Override>>
  public function init()[]: void {
    throw new LogicException(static::class);
  }

  <<__Override>>
  protected function render(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\Flow> $_descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  ): SGMLStreamInterfaces\Streamable {
    return <element />;
  }
}

final class TestAsynchronousElementWithWritableFlow
  extends SGMLStream\AsynchronousElementWithWritableFlow {
  use SGMLStream\IgnoreSuccessorFlow;

  <<__Override>>
  public function init()[]: void {
    throw new LogicException(static::class);
  }

  <<__Override>>
  protected async function renderAsync(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\WritableFlow>
      $_descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  ): Awaitable<SGMLStreamInterfaces\Streamable> {
    return <element />;
  }
}

final class TestSimpleElementWithWritableFlow
  extends SGMLStream\SimpleElementWithWritableFlow {
  use SGMLStream\IgnoreSuccessorFlow;

  <<__Override>>
  public function init()[]: void {
    throw new LogicException(static::class);
  }

  <<__Override>>
  protected function render(
    SGMLStreamInterfaces\Descendant<SGMLStreamInterfaces\WritableFlow>
      $_descendant_flow,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  ): SGMLStreamInterfaces\Streamable {
    return <element />;
  }
}

final class TestElementWithImpureInit extends SGMLStream\RootElement {
  const ctx INITIALZATION_CTX = [defaults];

  private bool $canStillDoImpureThings = false;

  <<__Override>>
  protected function init(): void {
    $this->canStillDoImpureThings = true;
  }

  <<__Override>>
  public function placeIntoSnippetStream(
    SGMLStreamInterfaces\SnippetStream $stream,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  ): void {
    $stream->addSafeSGML($this->canStillDoImpureThings ? 'pass' : 'fail');
  }
}
