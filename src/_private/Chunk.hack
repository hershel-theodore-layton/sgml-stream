/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\_Private;

use namespace HTL\{SGMLStream, SGMLStreamInterfaces};

final class Chunk {
  public string $buf = '';
  private ?SGMLStreamInterfaces\Snippet $snippet;

  public function setSnippet(
    SGMLStreamInterfaces\Snippet $snippet,
  )[write_props]: void {
    $this->snippet = $snippet;
  }

  public function getSnippet()[]: SGMLStreamInterfaces\Snippet {
    return $this->snippet ?? SGMLStream\NullSnippet::instance();
  }
}
