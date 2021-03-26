# sgml-stream

A streaming implementation of XHP for HHVM

## Alternative library

This library is an alternative for [xhp-lib](https://github.com/facebook/xhp-lib). Xhp-lib has been open sourced by Facebook. If you have never used xhp before, you can find [general xhp documentation](https://docs.hhvm.com/hack/XHP/introduction) here. This information describes how xhp (the underlying technology below xhp-lib and sgml-stream) works. It will often explain things from the perspective of xhp-lib. If you have a general understanding of xhp and the basics of xhp-lib. You can find [sgml-stream specific documentation](https://github.com/hershel-theodore-layton/sgml-stream/blob/master/docs/index.md) here. It will also help if you have a basic understanding of [async and await](https://docs.hhvm.com/hack/asynchronous-operations/introduction) in Hack.

## Heads-up

You **MUST** enable the `.hhconfig` setting `check_xhp_attribute` when using sgml-stream. We don't validate `@required` at runtime when you access an attribute. We trust that the typechecker has made sure all required attributes are present. Xhp-lib does validate `@required` at runtime. If you do not turn this setting on, your `@required` attributes might be `null` when read, which is not typesafe.

## Feature differences between xhp-lib and sgml-stream

### Rendering model

Xhp-lib is an amazing library which renders a tree of nodes, scalars, and xhp-lib specific interfaces to a string. Xhp-lib will manage coordination of Awaitables in your tree. Sgml-stream was born from the realization that xhp-lib, although be plenty fast, pushes back the time at which you can start sending content back in your http response. Xhp-lib renders trees of all the types into a tree of primitives first. Once that process completes, it turns this tree of primitives into a (long) string. Sgml-stream does things differently. Instead of returning your content as a string, we feed smaller partial strings to a Consumer. You are able to decide how and when you want to flush these smaller strings over the network.

Let's illustrate with the following example:

```HTML
<html>
  <head><link rel="stylesheet" src="..." /></head>
  <body>
    <MyFastAsynchronousElement id="a" />
    <MySlowAsynchronousElement id="b" />
    <MyFastAsynchronousElement id="c" />
  </body>
</html>
```

When rendering this tree with xhp-lib, all Awaitables fire at once. Once all the Awaitables finish, your tree gets turned into a string and returned from `node->toStringAsync(): Awaitable<string>`. However, everything before element `a` does not depend on the Awaitable inside of `a` resolving. Wouldn't it be nice if you could already _stream_ this content to your users? They will discover required resources early and start loading your css immediately. As it turns out, `MyFastAsynchronousElement` renders itself to something that contains an image tag. So users would benefit greatly from getting this content as soon as possible. They could start downloading your image and get a _partially rendered_ page sooner. In this example, everything until and including `<body>` can be sent immediately. `a` can be sent as soon as it is ready. `b` can be sent once it is ready and `a` has also completed. As the element name suggests, `b` is rather slow, so it will finish after `a` and stream immediately. If element `c` is done, `b` is not yet ready. This means that we can't stream it yet and we have to wait for `b` to complete. To read more about how we  do this, see [Streams, how do they work?](./docs/streams-how-do-they-work.md).

### Contexts v.s. Flow

Xhp-lib has a concept called `contexts`. It is essentially a `dict<string, mixed>` which is managed by xhp-lib and available to you when `element->renderAsync()` is called. You can call `->getContext()` and `->setContext()` to store values and retrieve them later. Sgml-stream does not implement contexts. Contexts were to difficult to get right when after we changed the rendering model.

Sgml-stream addresses this need in a different way. When your `SimpleUserElement->compose(Flow $flow): Streamable` method is called, you get access to a Flow. Flows support both constants and variables. The constant rules are relatively simple to explain. For a full explainer on Flow, including variables in flows, how variables and constants interact, and much more, see [The intricacies of Flow](./docs/the-intricacies-of-flow.md).

A Flow is a representation of your scope. Your scope is a single element large. If an element has descendants, their scopes are sub scopes. They can read your constants, but you can't read theirs. A constant can be declared with `WritableFlow->declareConstant(string $name, mixed $value): void`. If this declaration succeeds, it will declare the constant with `$name` for your scope. If it fails, a `RedeclaredConstantException` is thrown and the value remains unchanged. You can read constants from your flow using `Flow->get(string $name): mixed` and `Flow->getx(string $name): mixed`. The method with the `x` suffix throws a `ValueNotPresentException` when the Flow doesn't know about `$name`. `->get()` will return `null` when in this case. You can also query for the presence of `$name` using `Flow->has(string $name): bool`.

Let's illustrate with an example:

```HTML
<Element id="a" data-comment="I declare C1 to be 'apple'">
  <Element id="b" data-comment="I declare C2 to be 'banana'">
    <Element id="c" />
  </Element>
  <Element id="d" data-comment="I declare C2 to be 'dragon fruit'">
    <Element id="e" data-comment="I declare C3 to be 'elder berry'" />
    <Element id="f" />
  </Element>
</Element>
```

Element `a` declares a constant named `C1` with the value `'apple'`. `a` and all descendants of `a` can call `->getx('C1')` to get `'apple'`. `C1` lives in the scope `a` and the sub scopes `b`, `c`, `d`, `e`, and `f` can read from the `a` scope.

Element `b` declares a constant named `C2` with the value `'banana'`. `b` and all descendants of `b` can call `->getx('C2')` to get `'banana'`. `C2` lives in the scope `b` and the sub scope `c` can read from the `b` scope.

Element `d` declares a constant named `C2`. This constant was already declared in the `b` scope, but `d` is not a sub scope of `b`. Therefore, the call returns normally and `d` and all descendants of `d` can call `->getx('C2')` to get `'dragon fruit'`. This declaration would have failed if `c` attempted it, because `c` is a sub scope of `b`, so `C2` would already exist. You are not allowed to redeclare a constant.

Element `e` declares a constant named `C3`. `e` has no descendants, so `C3` is only visible to `e`. You might expect that `f` should be able to read from `e`. Do not confuse indentation level for scope. Even though `e` and `f` are at the same depth of the tree (they are siblings), **they do not share a scope**. This is to prevent strict order dependencies between `e` and `f`. If you want to have a constant be visible to both `e` and `f`, you should declare this constant in an ancestor.

### Immutability

Some may consider this a feature, others consider it a shortcoming of sgml-stream. Once an xhp open finishes. Which means that the `<a href="...">...</a>` object has been constructed, you can not modify the attributes, nor the children. This makes it easy to reason about the state of your xhp objects. `->appendChild()` and `->setAttribute()` (and friends) great tools when used correctly. We have been getting along fine without them, but there is a lot of xhp code out there that we do have visibility into. We might decide to weaken the immutability if enough issues for it get opened.  See [immutability why and how](./docs/immutability-why-and-how.md) for more information.

## How to get started

Sgml-stream does not come with any tags built-in. If you want to write html, you should also depend one or both of the following libraries:

 - [html-stream-namespaced](https://github.com/hershel-theodore-layton/html-stream-namespaced)
 - [html-stream-non-namespaced](https://github.com/hershel-theodore-layton/html-stream-non-namespaced)

They contain contain all the html tags from the [WhatWG HTML specification](https://html.spec.whatwg.org/multipage/). Xhp-lib comes with a couple more tags than those documented here. Namely: `<x:frag>`, `<doctype>`, `<conditional_comment>`, and some deprecated html tags. Here are some examples on how you could decide to implement them.

```HACK
// This code is not checked by the typechecker.
// If this code does not work anymore, please open an issue or a PR.
namespace MyOwnNamespace;

use type XHPChild;
use type HTL\SGMLStream\RootElement;
use type HTL\SGMLStreamInterfaces\{FragElement, SnippetStream};

final xhp class conditional_comment extends RootElement {
  attribute string if @required;

  <<__Override>>
  public function placeIntoSnippetStream(SnippetStream $stream): void {
    // This is unsafe, since the string passed for `->:if` could break out
    // of this comment and ruin your document. Be careful!
    $stream->addSafeSGML('<!--[if '.$this->:if.']>');
    $this->placeMyChildrenIntoSnippetStream($stream);
    $stream->addSafeSGML('<![endif]-->');
  }
}

final xhp class doctype extends RootElement {
  <<__Override>>
  public function placeIntoSnippetStream(SnippetStream $stream): void {
    $stream->addSafeSGML('<!DOCTYPE html>');
    $this->placeMyChildrenIntoSnippetStream($stream);
  }
}

final xhp class frag extends RootElement implements FragElement {
  // `frag` is treated like x:frag because of this  ^^^^^^^^^^^
  public function getFragChildren(): vec<XHPChild> {
    return $this->getChildren();
  }

  <<__Override>>
  public function placeIntoSnippetStream(SnippetStream $stream): void {
    $this->placeMyChildrenIntoSnippetStream($stream);
  }
}
```

As you can see from these examples, you get access to a **dangerous** method on SnippetStream, namely `->addSafeSGML(string $sgml): void`. You probably don't want to write your own elements this way if you can compose yourself using other tags. Extending `RootElement` directly is wordy and encourages unsafe strings to be passed to `->addSafeSGML()`. Most of the time, you should be using something else. This library includes base classes to hide the SnippetStream from you. `SimpleUserElement`, `SimpleUserElementWithWritableFlow`, `AsynchronousUserElement`, and `AsynchronousUserElementWithWritableFlow`. For a guide on how to choose between them, see [What element type do I need?](./docs/what-element-type-do-i-need.md) You can write your own too, since we haven't `<<__Sealed>>` `RootElement` off. If you decide to use a built-in base class, you'll implement a method with one of these signatures:
 - `SimpleUserElement->compose(Flow $flow): Streamable`
 - `SimpleUserElementWithWritableFlow->compose(WritableFlow $flow): Streamable`
 - `AsynchronousUserElement->composeAsync(Flow $flow): Awaitable<Streamable>`
 - `AsynchronousUserElementWithWritableFlow->composeAsync(WritableFlow $flow): Awaitable<Streamable>`

The `Flow` is yours for as long as your Hack scope lasts. Either via `return` or `throw`. If you are `async`, the `Flow` stays yours until your Awaitable resolves. Don't try to hold on to a Flow after that. If we implement more optimizations in the future, we will not consider it a BC break if your code behaves differently if you keep the `Flow` around.

You return a `Streamable` from these methods. This will be an `Element` in most cases, but all other `Streamable`s are also valid. So you can construct a markdown renderer, and return that. As long as you implement the `Streamable` interface on your markdown renderer, sgml-stream will understand what to do.

### Unsafe strings
A common question: _Why isn't a string Streamable?_

Answer: Strings can not implement interfaces that are not in hhvm already (`XHPChild`, and the deprecated `Stringish` come to mind). If you have a string (pcdata) in your element's children, you don't need to do something special. We'll run it through `htmlspecialchars()` and stream it for you.

A common response: No, I want to stream the string, without escaping it. Please don't mess with my strings.

Sigh...: There is a way to get what you want, but be careful what you wish for. The interface `ToSGMLStringAsync` is the thing you are looking for. This interface is an escape hatch which introduces security risks which might come back to bite you. This interface bypasses all parts of sgml-stream that try to keep you safe. It streams your string **directly with no escaping applied** to your consumer. This interface is meant to be used very sparingly.
