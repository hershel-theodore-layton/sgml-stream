# Flow kinds

_Historical note: Flow kinds were introduced in v1.0. In v0.x, `Flow` meant `Descendant<Flow>`, since there was no other kind of flow._

There are three kinds of `Flow`. Each of these flows is tagged with a `newtype` to help you distinguish them.

 - `Descendant<Flow>` The classic flow. Is handed from anchestor to descendant.
 - `Init<Flow>` A read-only flow to which even `DissolvableElement` has access.
 - `Successor<Flow>` A totally ordered flow. Is handed from predecessor to successor.

```HTML
<!-- Init<Flow> -->

<!-- Initialized before rendering the tree. -->
<!-- All elements in the tree get the same object. -->
<!-- Elements are not allowed to write to this Flow. -->
<T1 data-can-read="yes" data-can-write="no">
  <T2 data-can-read="yes" data-can-write="no">
    <T3 data-can-read="yes" data-can-write="no"/>
    <T4 data-can-read="yes" data-can-write="no"/>
  </T2>
  <T5 data-can-read="yes" data-can-write="no">
    <T6 data-can-read="yes" data-can-write="no"/>
  </T5>
</T1>
```

```HTML
<!-- Descendant<Flow> -->
<T1 data-flows-to="2,3,4,5,6">
  <T2 data-flows-to="3,4">
    <T3 data-flows-to="null"/>
    <T4 data-flows-to="null"/>
  </T2>
  <T5 data-flows-to="6">
    <T6 data-flows-to="null"/>
  </T5>
</T1>
```

```HTML
<!-- Successor<Flow> -->
<T1 data-flows-to="2,3,4,5,6">
  <T2 data-flows-to="3,4,5,6">
    <T3 data-flows-to="4,5,6"/>
    <T4 data-flows-to="5,6"/>
  </T2>
  <T5 data-flows-to="6">
    <T6 data-flows-to="null"/>
  </T5>
</T1>
```

## When to use which Flow?

For data that is static and known in advance, use `Init<Flow>`. This flow has the widest reach, since it is available at the `->placeIntoSnippetStream()` stage of the process. `DissolvableElement` does its rendering in this stage, so it has no chance to consume any other flows.

An `Init<Flow>` would be perfectly suited for things like `theme_preference`, `is_mobile_user_agent`, or `user_id`.

If the data needs to be available to elements in the tree, use `Descendant<Flow>`. This flow kind is mutable in a disciplined manner. Its mental model closely mirrors lexical scoping, which is familiar to most developers. This flow is the "classic" for a reason. Read access to this flow incurs no performance penalty. Getting write access is [almost always](#copying-a-flow) performant.

A `Descendant<Flow>` is suited for all kinds of data generated at any level of the tree. It is extremely useful when passing down data to `$this->getChildren()`.

If the data is rarely read, highly mutable, and append-like in nature, consider `Successor<Flow>`. There is only one `Successor<Flow>` (no copies are made during rendering). All access to the `Successor<Flow>` is strictly ordered. There are two modes of use when dealing with a `Successor<Flow>`

 - Deferred read and write access to this flow incur no performance penalty. If you can "schedule" your reads and writes from with your `render()` method, but you don't change your output based on the contents of this flow, you can defer your reads and writes.
 - Non-deferred Read and write access to this flow inside a `render()` method can incur a heavy performance cost. Your `render()` method will not be executed as soon as your parent is done rendering. Instead, your `render()` call is postponed until every predecessor is done and has written its content to the `Consumer`. If your element has children, those children won't be rendered either until all predecessors have written their contents to the `Consumer`.

The motivating example for using `Successor<Flow>` is:

```HTML
<!-- SomeScriptedElement generates a random id when it is rendered. -->
<!-- It "registers" itself on an object the the Successor<Flow> -->
<!-- WritesScriptTag sits at the bottom of the document and -->
<!-- receives the registrations in document order. -->
<!-- It can observe all changes from all predecessors, but -->
<!-- it is isolated from changes made by successors. -->
<body>
  <SomeScriptedElement data-random-id="a629561bcd1111">
    <SomeScriptedElement data-random-id="a629561bcd2222" />
  </SomeScriptedElement>
  <SomeScriptedElement data-random-id="a629561bcd3333" />
  <WritesScriptTag />
  <SomeRandomElement />
</body>
```

`WritesScriptTag` knows that every registration from the predecessors must have completed when its `render()` method is called. Therefore, it will not miss writing our an event listerer.

Before the introduction of `Successor<Flow>`, this pattern required creating your own `Snippet` class. You would also not be able to emit multiple `<WritesScriptTag />` elements on a page. The strict order imposed by `Successor<Flow>` makes it trivial to coordinate multiple `<WritesScriptTag />` elements on a page. Each `<WritesScriptTag />` will empty the registations it handled. The next will observe the registrations made by elements after the previous `<WritesScriptTag/>`

### Copying a flow

Copying a flow incurs copying one dict in `ExclamationConstFlow` and two dicts in `FirstComeFirstServedFlow`. The copy cost is propotional to the amount of keys stored. So if you have millions of variables and constants, this copy operation will not be performant anymore.
