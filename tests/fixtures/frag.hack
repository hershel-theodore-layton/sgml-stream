/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use type XHPChild;

final xhp class frag
  extends \HTL\SGMLStream\RootElement
  implements \HTL\SGMLStreamInterfaces\FragElement {
  const ctx INITIALIZATION_CTX = [];

  public function getFragChildren()[]: vec<XHPChild> {
    return $this->getChildren();
  }

  <<__Override>>
  public function placeIntoSnippetStream(
    \HTL\SGMLStreamInterfaces\SnippetStream $stream,
    \HTL\SGMLStreamInterfaces\Init<\HTL\SGMLStreamInterfaces\Flow> $init_flow,
  )[defaults]: void {
    $this->placeMyChildrenIntoSnippetStream($stream, $init_flow);
  }
}

function frag(?XHPChild ...$parts)[]: frag {
  return <frag>{$parts}</frag>;
}
