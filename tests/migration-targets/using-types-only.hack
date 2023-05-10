/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests\UsingTypesOnly\Source;

use type HTL\SGMLStream\{
  AsynchronousUserElement,
  AsynchronousUserElementWithWritableFlow,
  DissolvableUserElement,
  SimpleUserElement,
  SimpleUserElementWithWritableFlow,
};

use type HTL\SGMLStreamInterfaces\{Flow, Streamable, WritableFlow};

final class A extends DissolvableUserElement {
  <<__Override>>
  protected function compose(): Streamable {
    return <A />;
  }
}

final class B extends SimpleUserElement {
  <<__Override>>
  protected function compose(Flow $_flow): Streamable {
    return <B />;
  }
}

final class C extends SimpleUserElementWithWritableFlow {
  <<__Override>>
  protected function compose(WritableFlow $_flow): Streamable {
    return <C />;
  }
}

final class D extends AsynchronousUserElement {
  <<__Override>>
  protected async function composeAsync(Flow $_flow): Awaitable<Streamable> {
    return <D />;
  }
}

final class E extends AsynchronousUserElementWithWritableFlow {
  <<__Override>>
  protected async function composeAsync(Flow $_flow): Awaitable<Streamable> {
    return <E />;
  }
}
