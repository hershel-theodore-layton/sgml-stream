/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace HTL\{SGMLStream, SGMLStreamInterfaces};
use type XHPChild;

final xhp class frag
  extends SGMLStream\RootElement
  implements SGMLStreamInterfaces\FragElement {
  const ctx INITIALIZATION_CTX = [];

  public function getFragChildren()[]: vec<XHPChild> {
    return $this->getChildren();
  }

  <<__Override>>
  public function placeIntoSnippetStream(
    SGMLStreamInterfaces\SnippetStream $stream,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $init_flow,
  )[defaults]: void {
    $this->placeMyChildrenIntoSnippetStream($stream, $init_flow);
  }
}

function frag(?XHPChild ...$parts)[]: frag {
  return <frag>{$parts}</frag>;
}
