/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests\UsingNamespaceInterfaces\Source;

use namespace HTL\SGMLStreamInterfaces;

use type HTL\SGMLStream\{
  AsynchronousUserElement,
  AsynchronousUserElementWithWritableFlow,
  DissolvableUserElement,
  SimpleUserElement,
  SimpleUserElementWithWritableFlow,
};

final class A extends DissolvableUserElement {
  <<__Override>>
  protected function compose(): SGMLStreamInterfaces\Streamable {
    return <A />;
  }
}

final class B extends SimpleUserElement {
  <<__Override>>
  protected function compose(
    SGMLStreamInterfaces\Flow $_flow,
  ): SGMLStreamInterfaces\Streamable {
    return <B />;
  }
}

final class C extends SimpleUserElementWithWritableFlow {
  <<__Override>>
  protected function compose(
    SGMLStreamInterfaces\WritableFlow $_flow,
  ): SGMLStreamInterfaces\Streamable {
    return <C />;
  }
}

final class D extends AsynchronousUserElement {
  <<__Override>>
  protected async function composeAsync(
    SGMLStreamInterfaces\Flow $_flow,
  ): Awaitable<SGMLStreamInterfaces\Streamable> {
    return <D />;
  }
}

final class E extends AsynchronousUserElementWithWritableFlow {
  <<__Override>>
  protected async function composeAsync(
    SGMLStreamInterfaces\Flow $_flow,
  ): Awaitable<SGMLStreamInterfaces\Streamable> {
    return <E />;
  }
}
