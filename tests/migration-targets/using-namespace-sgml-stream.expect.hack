/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests\UsingNamespaceSgmlStream\Expect;

use namespace HTL\SGMLStream;
use type HTL\SGMLStreamInterfaces\{Flow, Streamable, WritableFlow};

final class A extends SGMLStream\DissolvableElement {
  <<__Override>>
  protected function render(Flow $_init_flow): Streamable {
    return <A />;
  }
}

final class B extends SGMLStream\SimpleElement {
  use SGMLStream\IgnoreSuccessorFlow;
  <<__Override>>
  protected function render(Flow $_flow, Flow $_init_flow): Streamable {
    return <B />;
  }
}

final class C extends SGMLStream\SimpleElementWithWritableFlow {
  use SGMLStream\IgnoreSuccessorFlow;
  <<__Override>>
  protected function render(WritableFlow $_flow, Flow $_init_flow): Streamable {
    return <C />;
  }
}

final class D extends SGMLStream\AsynchronousElement {
  use SGMLStream\IgnoreSuccessorFlow;
  <<__Override>>
  protected async function renderAsync(Flow $_flow, Flow $_init_flow): Awaitable<Streamable> {
    return <D />;
  }
}

final class E extends SGMLStream\AsynchronousElementWithWritableFlow {
  use SGMLStream\IgnoreSuccessorFlow;
  <<__Override>>
  protected async function renderAsync(
    Flow $_flow, Flow $_init_flow  ): Awaitable<Streamable> {
    return <E />;
  }
}
