/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

final class ConcatenatingStream implements SGMLStreamInterfaces\SnippetStream {
  private vec<_Private\Chunk> $chunks;
  private _Private\Chunk $lastChunk;

  public function __construct()[] {
    $this->lastChunk = new _Private\Chunk();
    $this->chunks = vec[$this->lastChunk];
  }

  public function addSafeSGML(string $safe_sgml)[write_props]: void {
    $this->lastChunk->buf .= $safe_sgml;
  }

  public function addSnippet(
    SGMLStreamInterfaces\Snippet $snippet,
  )[write_props]: void {
    $this->lastChunk->setSnippet($snippet);
    $this->lastChunk = new _Private\Chunk();
    $this->chunks[] = $this->lastChunk;
  }

  public function collect()[write_props]: vec<SGMLStreamInterfaces\Snippet> {
    $out = vec[];

    foreach ($this->chunks as $chunk) {
      $out[] = new SGMLSnippet($chunk->buf);
      $out[] = $chunk->getSnippet();
    }

    $this->lastChunk = new _Private\Chunk();
    $this->chunks = vec[$this->lastChunk];

    return $out;
  }

  public function streamOf(
    SGMLStreamInterfaces\Streamable $element,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $init_flow,
  )[defaults]: this {
    $me = new static();
    $element->placeIntoSnippetStream($me, $init_flow);
    return $me;
  }
}
