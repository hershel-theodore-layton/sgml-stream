/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests\UsingNamespacesOnly\Source;

use namespace HTL\{SGMLStream, SGMLStreamInterfaces};

final class A extends SGMLStream\DissolvableUserElement {
  <<__Override>>
  protected function compose(): SGMLStreamInterfaces\Streamable {
    return <A />;
  }
}

final class B extends SGMLStream\SimpleUserElement {
  <<__Override>>
  protected function compose(
    SGMLStreamInterfaces\Flow $_flow,
  ): SGMLStreamInterfaces\Streamable {
    return <B />;
  }
}

final class C extends SGMLStream\SimpleUserElementWithWritableFlow {
  <<__Override>>
  protected function compose(
    SGMLStreamInterfaces\WritableFlow $_flow,
  ): SGMLStreamInterfaces\Streamable {
    return <C />;
  }
}

final class D extends SGMLStream\AsynchronousUserElement {
  <<__Override>>
  protected async function composeAsync(
    SGMLStreamInterfaces\Flow $_flow,
  ): Awaitable<SGMLStreamInterfaces\Streamable> {
    return <D />;
  }
}

final class E extends SGMLStream\AsynchronousUserElementWithWritableFlow {
  <<__Override>>
  protected async function composeAsync(
    SGMLStreamInterfaces\Flow $_flow,
  ): Awaitable<SGMLStreamInterfaces\Streamable> {
    return <E />;
  }
}
