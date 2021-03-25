# What element type do I need?

## Elements which render by composing Streamable(s)

The `RootElement` base class should not be used when you want to compose your result from other tags / `Streamable`s. `RootElement` deals with `SnippetStream` directly. Direct access to `SnippetStream` is like wielding a chainsaw. You can make beautiful art with it (search for _Chainsaw art_), but inexperienced users might hurt themselves or others. `SnippetStream->addSafeSGML(string $sgml): void` should be avoided in almost all cases. This powerful tool is as close as you will get to writing directly to the network. **There is no filtering or escaping between you and the network when you call this method.** If you really do need it, skip this chapter.

Sgml-stream offers four useful base classes built-in. These should suffice for most uses. There are however other useful concepts out there that are not touched on by these four. If you want to use such a concept, you can write your own base class. The built-in base classes are:

 - `SimpleUserElement`
 - `SimpleUserElementWithWritableFlow`
 - `AsynchronousUserElement`
 - `AsynchronousUserElementWithWritableFlow`

`SimpleUserElement` should be your default base class. It has the highest performance out of the four offered here. You compose your result in `->compose(Flow $flow): Streamable` and return the result. You can read any value from you parent scopes on the `Flow`. Your own scope is read-only and empty. Sgml-stream does not expect you to write to your `Flow`. **DO NOT, I REPEAT, DO NOT** cast your `Flow` to a `WritableFlow`. `$flow as WritableFlow->assignVariable(...)` is NOT okay. If you need to assign variables or declare constants, use `SimpleUserElementWithWritableFlow`.

`SimpleUserElementWithWritableFlow` is identical in every way to `SimpleUserElement`, but it gives you a `WritableFlow`. Behind the scenes, we make a copy of your parent scope before your `->compose()` method is called. If you don't write to your `Flow`, see `SimpleUserElement`.

`AsynchronousUserElement` is a close second to `SimpleUserElement`. If you need to query a database or do some IO at the current level of the tree, `AsynchronousUserElement` is a perfect fit. You do not need to use `AsynchronousUserElement` if you yourself don't need to `await` anything. `SimpleUserElement` can have `AsynchronousUserElement` children and sgml-stream will handle this. You compose your result in an asynchronous context. `->composeAsync(Flow $flow): Awaitable<Streamable>`. Keep in mind that your children will not start to render until your Awaitable resolves. The reason behind this is that you may decide to ignore your children<sup>1</sup>. If you don't return them, we don't render them. Keep your work snappy and `__Memoize` is your friend.

`AsynchronousUserElementWithWritableFlow` is to `AsynchronousUserElement`, what `SimpleUserElementWithWritableFlow` is to `SimpleUserElement`. You know that you need it when you need it.

`1.` Ignoring your children is not a great idea, since although the children were not rendered, they were constructed. If you wanted to build an `<hide_if_false condition={$condition}>` tag, which returns an empty result when the condition is false and the children when true, **don't**. [Why Control Flows Should NOT Be In XHP](https://codebeforethehorse.tumblr.com/post/36089777404/why-control-flows-should-not-be-in-xhp) by Stefan Parker.

## I can't create my element using composition

Alright, we can deal with this. Are you implementing some sort of tag? Let's say a [web component](https://developer.mozilla.org/en-US/docs/Web/Web_Components)? We got you covered. We have three traits which deal with rendering custom tags. You'll need to use `ElementWithOpenAndCloseTags`. If your tag is a [void element](https://html.spec.whatwg.org/multipage/syntax.html#void-elements) (you only want an open tag, like `<img>`), you can use `ElementWithOpenTagOnly`. 

`ElementWithOpenAndCloseTagsAndUnescapedChildren` is used for `<style>` and `<script>`. You don't need to use it, unless you need to embed some [RAWTEXT](https://html.spec.whatwg.org/multipage/parsing.html#rawtext-state). This trait enforces that you have zero or one child. This child must be a string. This trait places this string between your tags **without escaping** it. It also attempts to prevent your content from accidentally closing the tag. **This is NOT a protection mechanism that should be relied upon.** SGML parsers are tricky and there might be cases that we simply didn't cover. We are no SGML parser writers and might have misinterpreted the spec, which leaves a door open to break out of the RAWTEXT state.

## I am not creating a tag

This is where our tools stop, since there are endless possibilities for what you are trying to do. Look into the `Streamable` interface. Be careful. You are on your own now. Build something that does what you need it to do, but no more. Prefer building wrapper around a MarkdownRenderer over a wrapper around a string. This tends to get overused. Be defensive and throw an exception if you are not sure you can maintain a strong guarantee of correctness. If you can't do either, use a really scary sounding name like: 
```HACK
class XSS_AND_PAINFUL_DEBUGGING_AWAITS_YOU__DO_NOT_USE implements Streamable {...}`
```

The `ToSGMLStringAsync` interface allows you to not bother about talking to the `SnippetStream`. If you wish to be embedded into an sgml-stream tree, and you don't want to have to change this code when sgml-stream changes, implement this. **This interface is just as unsafe as Streamable.** It creates the minimal amount of coupling between sgml-stream-interfaces and your code. So if sgml-stream changes, your code will continue to work.  
