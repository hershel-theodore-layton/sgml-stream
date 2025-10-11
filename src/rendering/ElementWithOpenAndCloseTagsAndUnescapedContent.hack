/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream;

use namespace HH\Lib\{C, Str};
use namespace HTL\{HH4Shim, SGMLStreamInterfaces};

trait ElementWithOpenAndCloseTagsAndUnescapedContent {
  require extends RootElement;
  private bool $hasBeenStreamed = false;

  /**
   * For `<style>`, use `style`. For `<script>`, use `script`.
   */
  abstract const string TAG_NAME;

  final public function placeIntoSnippetStream(
    SGMLStreamInterfaces\SnippetStream $stream,
    SGMLStreamInterfaces\Init<SGMLStreamInterfaces\Flow> $_init_flow,
  )[defaults]: void {
    if ($this->hasBeenStreamed) {
      throw new _Private\UseAfterRenderException(static::class);
    }
    $this->hasBeenStreamed = true;

    $opening_tag = render_opening_tag(
      static::TAG_NAME,
      $this->getDataAndAriaAttributes(),
      $this->getDeclaredAttributes(),
    );
    $closing_tag = '</'.static::TAG_NAME.'>';

    $stream->addSafeSGML($opening_tag);

    $children = $this->getChildren();
    $child_count = C\count($children);
    invariant(
      $child_count <= 1,
      '%s may only have one child, got %d',
      static::class,
      $child_count,
    );

    if ($child_count === 1) {
      $child = HH4Shim\to_mixed($children[0]);
      invariant(
        $child is string,
        '%s may only have one child and its type must be string',
        static::class,
      );
      // `</style>` is not the only way to end a <style>... block.
      // Weird things like `</style/>` work as well.
      // Just throw as soon as `</style` is detected.
      // This yields false positives for `</styles`, since
      // this is not a valid end tag for `<style>`.
      $closing_tag_prefix = '</'.static::TAG_NAME;
      // @see https://html.spec.whatwg.org/#script-data-state for script
      // @see https://html.spec.whatwg.org/#rawtext-state for style. Follow the
      // the `<`, `/`, (ASCII alpha) parser flow. You'll end up here
      // https://html.spec.whatwg.org/#script-data-end-tag-name-state or
      // https://html.spec.whatwg.org/#rawtext-end-tag-name-state here.
      // If this invariant does not protect against premature script data /
      // RAWTEXT end, please file a bug.
      invariant(
        !Str\contains_ci($child, $closing_tag_prefix),
        'The content contained something that could be interpreted as a '.
        'closing tag {%s}, which may cause your document to be parsed '.
        'incorrectly. If you control this content, try escaping this '.
        'problematic content. If you do not control this content, this might '.
        'be a failed injection attack.',
        Str\slice(
          $child,
          Str\search_ci($child, $closing_tag_prefix) as nonnull,
          Str\length($closing_tag_prefix),
        ),
      );
      $stream->addSafeSGML($child);
    }

    $stream->addSafeSGML($closing_tag);
  }
}
