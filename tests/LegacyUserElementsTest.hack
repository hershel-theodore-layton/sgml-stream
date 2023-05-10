/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\{SGMLStream, SGMLStreamInterfaces};
use function Facebook\FBExpect\expect;

use type Facebook\HackTest\HackTest;

final class LegacyUserElementsTest extends HackTest {
  public async function testLegacyElementsAreBackwardsCompatible(
  ): Awaitable<void> {
    $tree = <A><S><AW><SW><D><DumpFlow /></D></SW></AW></S></A>;

    $expected = '<element data-class="HTL\SGMLStream\Tests\A">'.
      '<element data-class="HTL\SGMLStream\Tests\S">'.
      '<element data-class="HTL\SGMLStream\Tests\AW">'.
      '<element data-class="HTL\SGMLStream\Tests\SW">'.
      '<element data-class="HTL\SGMLStream\Tests\D">'.
      '<element data-class="HTL\SGMLStream\Tests\DumpFlow">'.
      ' AW(AW wrote this) SW(SW wrote this) '.
      '</element></element></element></element></element></element>';

    expect(await $tree->toHTMLStringAsync())->toEqual($expected);
  }
}

final class S extends SGMLStream\SimpleUserElement {
  private bool $initCalled = false;
  <<__Override>>
  protected function init(): void {
    $this->initCalled = true;
  }
  <<__Override>>
  protected function compose(
    SGMLStreamInterfaces\Flow $_flow,
  ): SGMLStreamInterfaces\Streamable {
    invariant($this->initCalled, 'init not called');
    return <element data-class={static::class}>{$this->getChildren()}</element>;
  }
}

final class SW extends SGMLStream\SimpleUserElementWithWritableFlow {
  private bool $initCalled = false;
  <<__Override>>
  protected function init(): void {
    $this->initCalled = true;
  }
  <<__Override>>
  protected function compose(
    SGMLStreamInterfaces\WritableFlow $flow,
  ): SGMLStreamInterfaces\Streamable {
    invariant($this->initCalled, 'init not called');
    $flow->assignVariable(static::class, 'SW wrote this');
    return <element data-class={static::class}>{$this->getChildren()}</element>;
  }
}

final class A extends SGMLStream\AsynchronousUserElement {
  private bool $initCalled = false;
  <<__Override>>
  protected function init(): void {
    $this->initCalled = true;
  }
  <<__Override>>
  protected async function composeAsync(
    SGMLStreamInterfaces\Flow $_flow,
  ): Awaitable<SGMLStreamInterfaces\Streamable> {
    invariant($this->initCalled, 'init not called');
    return <element data-class={static::class}>{$this->getChildren()}</element>;
  }
}

final class AW extends SGMLStream\AsynchronousUserElementWithWritableFlow {
  private bool $initCalled = false;
  <<__Override>>
  protected function init(): void {
    $this->initCalled = true;
  }
  <<__Override>>
  protected async function composeAsync(
    SGMLStreamInterfaces\WritableFlow $flow,
  ): Awaitable<SGMLStreamInterfaces\Streamable> {
    invariant($this->initCalled, 'init not called');
    $flow->assignVariable(static::class, 'AW wrote this');
    return <element data-class={static::class}>{$this->getChildren()}</element>;
  }
}

final class D extends SGMLStream\DissolvableUserElement {
  private bool $initCalled = false;
  <<__Override>>
  protected function init(): void {
    $this->initCalled = true;
  }
  <<__Override>>
  protected function compose(): SGMLStreamInterfaces\Streamable {
    invariant($this->initCalled, 'init not called');
    return <element data-class={static::class}>{$this->getChildren()}</element>;
  }
}

final class DumpFlow extends SGMLStream\SimpleUserElement {
  <<__Override>>
  protected function compose(
    SGMLStreamInterfaces\Flow $flow,
  ): SGMLStreamInterfaces\Streamable {
    return
      <element data-class={static::class}>
        AW({$flow->get(AW::class) as ?\XHPChild})
        SW({$flow->get(SW::class) as ?\XHPChild})
      </element>;
  }
}
