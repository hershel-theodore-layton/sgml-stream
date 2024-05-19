/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HTL\SGMLStreamInterfaces;

/**
 * Base class for elements which wrap another Streamable.
 * This is the leanest type of Element there is. It dissolves immediately when
 * being added to a stream instead of using a Snippet which dissolves later in
 * the pipeline. This is useful for small conceptually pure elements with really
 * cheap render methods.
 *
 * This is especially useful if you want to add a `padding` attribute to `div`
 * or automate the creation of `<picture>` elements for webp and avif images.
 *
 * A note about exceptions:
 * If your render() throws, it will bubble up in the ->placeIntoSnippetStream()
 * stage, instead of the ->primeAsync() or ->feedBytesToConsumerAsync() stages.
 *
 * A note for people optimizing their xhp trees:
 * This is especially useful when wrapping elements that render to a string.
 * Given this xhp expression `<div><span></span></div>` a ConcatenatingStream
 * will append: "<div", ">", "<span", ">", "</span>", "</div>" to the same string
 * without any overhead. If we used a SimpleElement wrapping a span, more
 * overhead would be incurred. `<div><MySpan></MySpan></div>` would append like
 * so: "<div", ">", end string, Snippet-For-MySpan, new string, "</div>".
 * The Snippet-For-MySpan broke up this string, causing more tiny strings and
 * tiny Snippet objects to float around in your program. If MySpan was a
 * dissolvable element instead, the inner xhp expression `<span></span>` would
 * be appended to the stream, instead of the wrapping ComposableSnippet. This
 * results in longer strings and fewer objects inside of the ConcatenatingStream.
 */
abstract xhp class DissolvableElement extends RootElement {
  const ctx INITIALZATION_CTX = [];
  /**
   * Return your representation by composing something Streamable.
   * Do it quickly, as this work happens before the async machine is started.
   */
  abstract protected function render(
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $init_flow,
  )[defaults]: SGMLStreamInterfaces\Streamable;

  <<__Override>>
  final public function placeIntoSnippetStream(
    SGMLStreamInterfaces\SnippetStream $stream,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $init_flow,
  )[defaults]: void {
    $this->render($init_flow)->placeIntoSnippetStream($stream, $init_flow);
  }
}
