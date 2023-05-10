/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests\UsingNamespaceSgmlStream\Source;

use namespace HTL\SGMLStream;
use type HTL\SGMLStreamInterfaces\{Flow, Streamable, WritableFlow};

final class A extends SGMLStream\DissolvableUserElement {
  <<__Override>>
  protected function compose(): Streamable {
    return <A />;
  }
}

final class B extends SGMLStream\SimpleUserElement {
  <<__Override>>
  protected function compose(Flow $_flow): Streamable {
    return <B />;
  }
}

final class C extends SGMLStream\SimpleUserElementWithWritableFlow {
  <<__Override>>
  protected function compose(WritableFlow $_flow): Streamable {
    return <C />;
  }
}

final class D extends SGMLStream\AsynchronousUserElement {
  <<__Override>>
  protected async function composeAsync(Flow $_flow): Awaitable<Streamable> {
    return <D />;
  }
}

final class E extends SGMLStream\AsynchronousUserElementWithWritableFlow {
  <<__Override>>
  protected async function composeAsync(
    Flow $_flow,
  ): Awaitable<Streamable> {
    return <E />;
  }
}
