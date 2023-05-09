# Streams, how do they work?

This document tries to give you a feel for the stream pipeline. You don't need to understand this to write good sgml-stream code. However, if you want to do something custom or demanding, it helps to understand how the machinery works. That will allow you to write classes which respect the constraints they are put under.

Streaming happens in three phases:

 - Constructing a snippet stream from a tree
 - Priming the stream
 - Consuming the primed stream

I'll explain this twice, once for a tree without `UserElement`s, and once for a tree with `UserElement`s

_UserElement used to be part of the classname of every user extendable class in this library. This convention has since been dropped. The XXXUserElement classes are deprecated and only present for backwards compatibility. In this document UserElement refers to any class which renders through a Snippet. (Notable exception, DissolvableElement does not use a Snippet.)_

## Constructing a SnippetStream from a tree without UserElements

When serializing an sgml tree to a network or a string, the first step is determining the order in which parts of the tree should appear in the text representation. This requires [traversing the tree](https://en.wikipedia.org/wiki/Tree_traversal). Sgml-stream represents this concept using a `SnippetStream`. Each visited entity in the tree creates one or more `Snippet`s. These snippets are appended to the stream. Once the entire tree has been traversed, you are left with a (long) vec of `Snippet`s. It is crucial that they appear in document order.

Let's illustrate this with a tree of native html elements.

```HTML
<html>
  <head class="my class"></head>
  <body>
    <h1 class="red">Hello, World!</h1>
  </body>
</html>
```

It might be helpful to visualize this tree in JSON form too.

```JSON
{
  "tag": "html",
  "attributes": null,
  "children": [
    {
      "tag": "head",
      "attributes": {"class": "my class"},
      "children": null
    },
    {
      "tag": "body",
      "attributes": null,
      "children": [
        {
          "tag": "h1",
          "attributes": {"class": "red"},
          "children": [
            "Hello, World!"
          ]
        }
      ]
    }
  ]
}
```

Let's convert this representation into a `SnippetStream`.

`html` is the top level element of this tree. We start at `html`. `html` creates a Snippet with the value `<html>`. Then the children of `html` can convert themselves. `head` creates a Snippet with the value `<head class="my class">`. Since `head` has no children, it immediately creates another, with the value `</head>`. The next child of `html` gets a go. `body` creates a Snippet with the value `<body>`. Now the children of `body` can convert themselves. `h1` creates a Snippet with the value `<h1 class="red">`. The only child of `h1` is a text node. Text nodes are automatically escaped by sgml-stream. Escaping `Hello, World!` yields `Hello, World!`. So the Snippet with the value of `Hello, World!` is appended to the stream. Now `h1` appends a Snippet with the value `</h1>`. Now `body` appends a closing tag with with value of `</body>`. Finally `html` appends its own closing tag with the value of `</html>`. What you are left with is the following `SnippetStream`:

```JSON
[
  "<html>", "<head class=\"my class\">", "</head>",
  "<body>", "<h1 class=\"red\">", "Hello, World!",
  "</h1>", "</body>" "</html>"
]
```

## Priming the SnippetStream without UserElements

In the next step, we hand this `SnippetStream` to a `Renderer`. The `Renderer` requires a `Flow`. This `Flow` is used as the `Descendant<Flow>` When converting a tree to a `SnippetStream`, we didn't have a `Descendant<Flow>` yet. We only has the `Init<Flow>`. The `Renderer` collects the `Snippet`s from the `SnippetStream`. It then calls `->primeAsync(Descendant<CopyableFlow> $flow): Awaitable<void>` on each of them and stores the Awaitables. Each `Snippet` will now fire of all the work it needed to do. Since the `SnippetStream` we just created doesn't need to do any work, this step is a noop.

## Consuming the primed SnippetStream without UserElements

After collecting all Awaitables from the `->primeAsync()` calls, **but before `await`ing them**, we start the next step. We loop over all the `Snippet`s in turn, whilst concurrently awaiting the Awaitables. We call `->feedBytesToConsumerAsync(Consumer $consumer): Awaitable<void>` on the `Snippet`s in order. If all the work that a `Snippet` needs to do has already finished, it will call `Consumer->consumeAsync()` immediately. Our `SnippetStream` does not have any work to do after construction, so `Consumer` is fed all the strings at a high rate. Once this process completes, the `Renderer` calls `Consumer->theDocumentIsCompleteAsync()` and `await`s the returned `Awaitable`. Once it resolves, the rendering is done.

## Constructing a SnippetStream from a tree with UserElements

The implementations of the built-in UserElements return a custom `Snippet` type for the kind of work they do. This means that we do not drill into UserElements when constructing a `SnippetStream`.

Let's illustrate with an example:

```HTML
<div>
  <MyElement>
    <span>
      <MyOtherElement />
    </span>
  </MyElement>
</div>
```

And also the JSON view:

```JSON
[
  {
    "tag": "div",
    "attributes": null,
    "children": [
      {
        "tag": "MyElement",
        "attributes": null,
        "children": [
          {
            "tag": "span",
            "attributes": null,
            "children": [
              {
                "tag": "MyOtherElement",
                "attributes": null,
                "children": null
              }
            ]
          }
        ]
      }
    ]
  }
]
```

`MyElement` is a `SimpleElement` and `MyOtherElement` is an `AsynchronousElement`. When constructing a `SnippetStream` from this subtree, we might not make as many `Snippet`s as you might expect, but that is fine. They will be made later when needed.

`div` is the top level element. Just like before, a new Snippet with the value `<div>` is created. Then the children of `div` get their turn. `MyElement` is not a plain SGML element. In order to render, it needs a `Flow`, which is not yet available at this step. If `MyElement` is a `SimpleElement`, a snippet with the value `ComposableSnippet($this, $descendant_flow ==> tuple($stream->streamOf($this->render($descendant_flow, $init_flow), $init_flow), $descendant_flow))` is created. We don't recurse down into the children of `MyElement`, since `MyElement` may decide to ignore its children. If it does, why spend any time on them? This means that we return control back to `div`, since their are no siblings of `MyElement`. `div` adds a Snippet with the value `</div>` and we are done. We are left with the following SnippetStream.

```JSON
["<div>", "ComposableSnippet of SimpleElement", "</div>"]
```

## Priming a SnippetStream with UserElements

In the next step, the Renderer gets a go. The renderer _has_ a `Descendant<Flow>` available. This was not present in the previous step. After collecting the 3 `Snippet`s from the `SnippetStream`, we prime all the `Snippet`s. `<div>` and `</div>` don't need to be primed, therefore these calls are just a noop. The `ComposableSnippet` _does_ do some work when being primed. Namely, it runs `SimpleElement->render($descendant_flow, $init_flow)`, with the `Descendant<Flow>` the `Renderer` gave it. `->render()` is not `async`, so it runs greedily. When `->render()` returns a `Streamable`, the `ComposableSnippet` knows how the `SimpleElement` wants to be rendered. It takes returned `Streamable`, and converts this into a new `SnippetStream`. Let's say for the sake of example, that `MyElement` has this definition.

```PHP
final xhp class MyElement extends SimpleElement {
  <<__Override>>
  protected function render(Descendant<Flow> $descendant_flow, Init<Flow> $_init_flow): Streamable {
    return <div class={$descendant_flow->getx('dark-theme') ? "night" : "bright"}>
      {$this->getChildren()}
    </div>;
  }
}
```

This yields the following sub tree.

```HTML
<div class="night">
  <span>
    <MyOtherElement />
  </span>
</div>
```

```JSON
[
  {
    "tag": "div",
    "attributes": "night",
    "children": [
      {
        "tag": "span",
        "attributes": null,
        "children": [
          {
            "tag": "MyOtherElement",
            "attributes": null,
            "children": null
          }
        ]
      }
    ]
  }
]
```

This gets turned into a `SnippetStream` again. I'll skip the prose and show you the new `SnippetStream` immediately.

```JSON
[
  "<div class=\"night\">", "<span>",
  "AwaitableSnippet of AsynchronousElement",
  "</span>", "</div>"
]
```

These `Snippet`s are looped over and their `->primeAsync()` method gets invoked from within the `->primeAsync()` call on `ComposableSnippet`. The SGML ones are once again noop methods. The `AwaitableSnippet->primeAsync(Descendant<CopyableFlow> $flow): Awaitable<void>` method invokes `->renderAsync(Descendant<Flow> $descendant_flow, Init<Flow> $init_flow): Awaitable<Streamable>` on the `AsynchronousElement`. Let's assume that fetches some response from an API. When we `await` all these Awaitables concurrently, `ComposableSnippet->primeAsync()` returns back to the `Renderer`. The `Renderer` does not yet `await` these Awaitables. They are awaited in the next step. The Awaitables have formed the following dependency graph.

```JSON
[
  {
    "snippet": "<div>",
    "depends on": null
  },
  {
    "snippet": "ComposableSnippet",
    "depends on": [
      {
        "snippet": "<div class=\"night\">",
        "depends on": null
      },
      {
        "snippet": "<span>",
        "depends on": null
      },
      {
        "snippet": "AwaitableSnippet",
        "depends on": "MyOtherElement->renderAsync()"
      },
      {
        "snippet": "</span>",
        "depends on": null
      },
      {
        "snippet": "</div>",
        "depends on": null
      }
    ]
  },
  {
    "snippet": "</div>",
    "depends on": null
  }
]
```

When `MyOtherElement->renderAsync()`'s Awaitable resolves, `AwaitableSnippet` would create another `SnippetStream` for the `Streamable` returned from there. This `Streamable` could be a `AwaitableSnippet` again. Then the same course of events would take place. At some point however, the inner `Snippet` returns something that does not yield yet more snippets. At which point, no new `Snippet`s are being created.

## Consuming a SnippetStream with UserElements

The previous step set as many Awaitables in motion as it could. However, they were not `await`ed by the `Renderer`. This means that the `Renderer` does not wait for I/O to finish in the previous step. So the API call from the example is not pushing back your time to first byte.

We then `await` the 3 top level `Awaitable`s from the top level `->primeAsync()` calls. We concurrently start looping over the `Snippet` and try to get bytes of content from them.

`<div>` is ready immediately, so this gets fed to the consumer right there and then. We then give control to `ComposableSnippet->feedBytesToConsumerAsync()`, were we will spend the longest amount of time. Within this `ComposableSnippet`, there are 5 `Snippet`s. `<div class="night">` and `<span>` are ready, since there is no I/O between them and the `Renderer`. They are fed to the `Consumer` immediately. `ComposableSnippet` then hands control to `AwaitableSnippet->feedToConsumerAsync()`. Although the `Awaitable` has already been running for a short while, it is not ready yet. The API has not responded yet. 

`AwaitableSnippet` decides to notify the `Consumer` that the next bit of content is stuck behind `await`ing something using `Consumer->receiveWaitNotificationAsync()`. The `Consumer` _might_ use this down time to flush some buffer to the network. It might also return immediately, depending on what _you_ want it to do. If the API response comes back whilst the `Consumer`s Awaitable is not resolved yet, we **can not** continue. The contract of `Consumer` does not require correct behavior when two methods are called on it at the same time. This means that you should be careful about the work you decide to do in this notification method. You could end up stalling the `Renderer`.

The API response is back and the `Consumer` is also done. Let's create a `SnippetStream` from the result of `->renderAsync()` quickly. We consume this stream and the `Awaitable` from `AwaitableSnippet->feedBytesToConsumer()` resolves. `ComposableSnippet` was waiting for that. It then feeds the remaining `</span>` and `</div>` to the `Consumer`. When that completes, its own returned `Awaitable` resolves. The `Renderer` can finally move on to the last `</div>` and call `Consumer->theDocumentIsCompleteAsync()`. The document is complete and the `Renderer` returns from `Renderer->renderAsync()`.

## Multiple async operations in one tree

The previous example only had a single `AsynchronousElement`. Real world webpages will have way more `AsynchronousElement`s in them. Keep in mind that an element which is nested inside of another like this `<A><B></B></A>` does not get primed before the outer element resolves. If there is no data dependency between `A` and `B`, your tree will have fewer `Awaitable`s running at once which reduces the amount of work done concurrently. If you have a choice between nesting `A` in `B` or making them siblings, prefer siblings. That way, both `A` and `B` can `await` at the same time.

If you have multiple `AsynchronousElement`s in your tree, `->primeAsync()` may resolve in any order. We run as many `Awaitable`s as we can at the same time. If an `Awaitable` at the end of the tree resolves before one at the beginning, its return value will get turned into a `SnippetStream` first. It will get primed immediately afterwards. The only process which does always happen in order is `->feedBytesToConsumerAsync()`.
