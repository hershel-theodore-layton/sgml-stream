/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests\UsingNamespacesOnly\Expect;

use namespace HTL\{SGMLStream, SGMLStreamInterfaces};

final class A extends SGMLStream\DissolvableElement {
  <<__Override>>
  protected function render(SGMLStreamInterfaces\Flow $_init_flow): SGMLStreamInterfaces\Streamable {
    return <A />;
  }
}

final class B extends SGMLStream\SimpleElement {
  use SGMLStream\IgnoreSuccessorFlow;
  <<__Override>>
  protected function render(
    SGMLStreamInterfaces\Flow $_flow, SGMLStreamInterfaces\Flow $_init_flow  ): SGMLStreamInterfaces\Streamable {
    return <B />;
  }
}

final class C extends SGMLStream\SimpleElementWithWritableFlow {
  use SGMLStream\IgnoreSuccessorFlow;
  <<__Override>>
  protected function render(
    SGMLStreamInterfaces\WritableFlow $_flow, SGMLStreamInterfaces\Flow $_init_flow  ): SGMLStreamInterfaces\Streamable {
    return <C />;
  }
}

final class D extends SGMLStream\AsynchronousElement {
  use SGMLStream\IgnoreSuccessorFlow;
  <<__Override>>
  protected async function renderAsync(
    SGMLStreamInterfaces\Flow $_flow, SGMLStreamInterfaces\Flow $_init_flow  ): Awaitable<SGMLStreamInterfaces\Streamable> {
    return <D />;
  }
}

final class E extends SGMLStream\AsynchronousElementWithWritableFlow {
  use SGMLStream\IgnoreSuccessorFlow;
  <<__Override>>
  protected async function renderAsync(
    SGMLStreamInterfaces\Flow $_flow, SGMLStreamInterfaces\Flow $_init_flow  ): Awaitable<SGMLStreamInterfaces\Streamable> {
    return <E />;
  }
}
