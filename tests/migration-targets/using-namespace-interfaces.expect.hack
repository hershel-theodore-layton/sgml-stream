/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests\UsingNamespaceInterfaces\Expect;

use namespace HTL\SGMLStreamInterfaces;

use type HTL\SGMLStream\{
  AsynchronousElement,
  AsynchronousElementWithWritableFlow,
  DissolvableElement,
  SimpleElement,
  SimpleElementWithWritableFlow,
};

final class A extends DissolvableElement {
  <<__Override>>
  protected function render(SGMLStreamInterfaces\Flow $_init_flow): SGMLStreamInterfaces\Streamable {
    return <A />;
  }
}

final class B extends SimpleElement {
  use \HTL\SGMLStream\IgnoreSuccessorFlow;
  <<__Override>>
  protected function render(
    SGMLStreamInterfaces\Flow $_flow, SGMLStreamInterfaces\Flow $_init_flow  ): SGMLStreamInterfaces\Streamable {
    return <B />;
  }
}

final class C extends SimpleElementWithWritableFlow {
  use \HTL\SGMLStream\IgnoreSuccessorFlow;
  <<__Override>>
  protected function render(
    SGMLStreamInterfaces\WritableFlow $_flow, SGMLStreamInterfaces\Flow $_init_flow  ): SGMLStreamInterfaces\Streamable {
    return <C />;
  }
}

final class D extends AsynchronousElement {
  use \HTL\SGMLStream\IgnoreSuccessorFlow;
  <<__Override>>
  protected async function renderAsync(
    SGMLStreamInterfaces\Flow $_flow, SGMLStreamInterfaces\Flow $_init_flow  ): Awaitable<SGMLStreamInterfaces\Streamable> {
    return <D />;
  }
}

final class E extends AsynchronousElementWithWritableFlow {
  use \HTL\SGMLStream\IgnoreSuccessorFlow;
  <<__Override>>
  protected async function renderAsync(
    SGMLStreamInterfaces\Flow $_flow, SGMLStreamInterfaces\Flow $_init_flow  ): Awaitable<SGMLStreamInterfaces\Streamable> {
    return <E />;
  }
}
