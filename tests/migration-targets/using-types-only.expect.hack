/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests\UsingTypesOnly\Expect;

use type HTL\SGMLStream\{
  AsynchronousElement,
  AsynchronousElementWithWritableFlow,
  DissolvableElement,
  SimpleElement,
  SimpleElementWithWritableFlow,
};

use type HTL\SGMLStreamInterfaces\{Flow, Streamable, WritableFlow};

final class A extends DissolvableElement {
  <<__Override>>
  protected function render(Flow $_init_flow): Streamable {
    return <A />;
  }
}

final class B extends SimpleElement {
  use \HTL\SGMLStream\IgnoreSuccessorFlow;
  <<__Override>>
  protected function render(Flow $_flow, Flow $_init_flow): Streamable {
    return <B />;
  }
}

final class C extends SimpleElementWithWritableFlow {
  use \HTL\SGMLStream\IgnoreSuccessorFlow;
  <<__Override>>
  protected function render(WritableFlow $_flow, Flow $_init_flow): Streamable {
    return <C />;
  }
}

final class D extends AsynchronousElement {
  use \HTL\SGMLStream\IgnoreSuccessorFlow;
  <<__Override>>
  protected async function renderAsync(Flow $_flow, Flow $_init_flow): Awaitable<Streamable> {
    return <D />;
  }
}

final class E extends AsynchronousElementWithWritableFlow {
  use \HTL\SGMLStream\IgnoreSuccessorFlow;
  <<__Override>>
  protected async function renderAsync(Flow $_flow, Flow $_init_flow): Awaitable<Streamable> {
    return <E />;
  }
}
