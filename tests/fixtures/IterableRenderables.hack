/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\SGMLStreamInterfaces;
use type HH\Iterator;
use type IteratorAggregate;

final class IterableStreamable
  implements SGMLStreamInterfaces\Streamable, IteratorAggregate<string> {
  public int $renderCalls = 0;

  public function getIterator()[]: Iterator<string> {
    yield 'iteration view';
  }

  public function placeIntoSnippetStream(
    SGMLStreamInterfaces\SnippetStream $stream,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  )[defaults]: void {
    $this->renderCalls++;
    $stream->addSafeSGML('<b>stream view</b>');
  }
}

final class IterableStringRenderable
  implements SGMLStreamInterfaces\ToSGMLStringAsync, IteratorAggregate<string> {
  public int $renderCalls = 0;

  public function getIterator()[]: Iterator<string> {
    yield 'iteration view';
  }

  public async function toHTMLStringAsync()[defaults]: Awaitable<string> {
    $this->renderCalls++;
    return '<i>string view</i>';
  }
}
