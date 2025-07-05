/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\{SGMLStream, SGMLStreamInterfaces, TestChain};
use function HTL\Expect\expect;

<<TestChain\Discover>>
function legacy_user_elements_test(TestChain\Chain $chain)[]: TestChain\Chain {
  return $chain->group(__FUNCTION__)
    ->testAsync(
      'testLegacyElementsAreBackwardsCompatible',
      async ()[defaults] ==> {
        $tree = <A><S><AW><SW><D><DumpFlow /></D></SW></AW></S></A>;

        $expected = '<element data-class="HTL\SGMLStream\Tests\A">'.
          '<element data-class="HTL\SGMLStream\Tests\S">'.
          '<element data-class="HTL\SGMLStream\Tests\AW">'.
          '<element data-class="HTL\SGMLStream\Tests\SW">'.
          '<element data-class="HTL\SGMLStream\Tests\D">'.
          '<element data-class="HTL\SGMLStream\Tests\DumpFlow">'.
          ' AW(AW wrote this) SW(SW wrote this) '.
          '</element></element></element></element></element></element>';

        expect(await render_async($tree))->toEqual($expected);
      },
    );
}

async function render_async(
  SGMLStreamInterfaces\Streamable $streamable,
)[defaults]: Awaitable<string> {
  $stream = new SGMLStream\ConcatenatingStream();

  $streamable->placeIntoSnippetStream(
    $stream,
    SGMLStream\FirstComeFirstServedFlow::createEmpty(),
  );

  $renderer = new SGMLStream\ConcurrentSingleUseRenderer($stream);
  $consumer = new SGMLStream\ToStringConsumer();
  await $renderer->renderAsync(
    $consumer,
    SGMLStream\FirstComeFirstServedFlow::createEmpty(),
  );
  return $consumer->toString();
}

final class S extends SGMLStream\SimpleUserElement {
  <<__Override>>
  protected function compose(
    SGMLStreamInterfaces\Flow $_flow,
  )[]: SGMLStreamInterfaces\Streamable {
    return <element data-class={static::class}>{$this->getChildren()}</element>;
  }
}

final class SW extends SGMLStream\SimpleUserElementWithWritableFlow {
  <<__Override>>
  protected function compose(
    SGMLStreamInterfaces\WritableFlow $flow,
  )[write_props]: SGMLStreamInterfaces\Streamable {
    $flow->assignVariable((string)static::class, 'SW wrote this');
    return <element data-class={static::class}>{$this->getChildren()}</element>;
  }
}

final class A extends SGMLStream\AsynchronousUserElement {
  <<__Override>>
  protected async function composeAsync(
    SGMLStreamInterfaces\Flow $_flow,
  )[]: Awaitable<SGMLStreamInterfaces\Streamable> {
    return <element data-class={static::class}>{$this->getChildren()}</element>;
  }
}

final class AW extends SGMLStream\AsynchronousUserElementWithWritableFlow {
  <<__Override>>
  protected async function composeAsync(
    SGMLStreamInterfaces\WritableFlow $flow,
  )[write_props]: Awaitable<SGMLStreamInterfaces\Streamable> {
    $flow->assignVariable((string)static::class, 'AW wrote this');
    return <element data-class={static::class}>{$this->getChildren()}</element>;
  }
}

final class D extends SGMLStream\DissolvableUserElement {
  <<__Override>>
  protected function compose()[]: SGMLStreamInterfaces\Streamable {
    return <element data-class={static::class}>{$this->getChildren()}</element>;
  }
}

final class DumpFlow extends SGMLStream\SimpleUserElement {
  <<__Override>>
  protected function compose(
    SGMLStreamInterfaces\Flow $flow,
  )[]: SGMLStreamInterfaces\Streamable {
    return
      <element data-class={static::class}>
        AW({$flow->get((string)AW::class) as ?\XHPChild})
        SW({$flow->get((string)SW::class) as ?\XHPChild})
      </element>;
  }
}
