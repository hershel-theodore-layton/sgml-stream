# Upgrading from v0 to v1

_This document includes change from the sgml-stream-interfaces project and the sgml-stream project._

## What's new?

This release introduces three major features and a couple minor improvements.

 - Access to an `Init<Flow>` in any element (including dissolvable element)!
 - The new `Successor<Flow>` introduces a communication channel with successors!
 - `AsynchronousElementWithSuccessorFlow` render with the `Successor<Flow>`!

---

 - The new class `ConcurrentReusableRenderer` supports the new flow kinds.
 - The new `CallbackSuccessorFlow` and `IgnoreSuccessorFlow` simplify carrying state from `render()` (previously `compose()`) to the `Successor<Flow>`.
 - `NullSnippet` now exposes a shared `::instance()` to encourage reuse.

## Breaking changes

**Almost all your code can remain unchanged!** This release includes the minimal amount of breaking changes. The impact of every change was carefully considered. Every breaking change was absolutely necessary to introduce new features `Init<Flow>` and `Successor<Flow>`.

The **public** method `SnippetStream->streamOf()`, the **public** method `Streamable->placeIntoSnippetStream()`, the **final protected** method `RootElement->placeMyChildrenIntoSnippetStream()`, and the **final protected** method `RootElement->placeTraversableIntoSnippetStream()` the now take an `Init<Flow>` where it did not before. It would not have been possible to introduce the `Init<Flow>` feature without this change.

```DIFF
// SnippetStream
public function streamOf(
  Streamable $streamable,
+  Init<Flow> $init_flow
): this;

// Streamable
public function placeIntoSnippetStream(
  SnippetStream $stream,
+  Init<Flow> $init_flow,
): void;

// RootElement
final protected function placeMyChildrenIntoSnippetStream(
  SnippetStream $stream,
+  Init<Flow> $init_flow,
): void;

// RootElement
final protected static function placeTraversableIntoSnippetStream(
  SnippetStream $stream,
+  Init<Flow> $init_flow,
  Traversable<mixed> $children,
): void;
```

---

_These changes are unlikely to affect you. They affect the `Snippet` interface. Iff you created your own **direct** subclasses of `RootElement`, these will affect you._

The **final** classes `AwaitableSnippet` and `ComposableSnippet` have undergone some changes.

Their new constructor signatures:

```DIFF
public function __construct(
+  CanProcessSuccessorFlow $processSuccessorFlow,
  (function(
-    CopyableFlow
+    Descendant<CopyableFlow>,
  ):
- SnippetStream
+ (SnippetStream, Descendant<CopyableFlow>)
 ) $childFunc,
)

public function __construct(
  SGMLStreamInterfaces\CanProcessSuccessorFlow $processSuccessorFlow,
  (function(
-    CopyableFlow,
+    Descendant<CopyableFlow>,
  ): Awaitable<
-    SnippetStream
+    (SnippetStream, Descendant<CopyableFlow>)
  >) $childFunc,
)
```

The following breaking changes were inherited via the `Snippet` interface and apply to all snippets:

A `Successor<WritableFlow>` argument is added to their **public** `feedBytesToConsumerAsync()` methods.

```DIFF
public async function feedBytesToConsumerAsync(
  Consumer $consumer,
+  Successor<WritableFlow> $successor_flow,
): Awaitable<void>
```

The argument to `primeAsync()` is now a `Descendant<CopyableFlow>` instead of a plain `CopyableFlow`.

```DIFF
public function primeAsync(
-  CopyableFlow $flow
+  Descendant<CopyableFlow> $flow
): Awaitable<void>;
```

The changes were required to add the `Successor<Flow>` feature.

---

The following methods have been removed from `RootElement`:

 - `final protected function __flushSubtree(): Awaitable<nothing>`
 - `final public static function __xhpReflectionAttributes(): dict<string, nothing>`
 - `protected static function __legacySerializedXHPChildrenDeclaration(): mixed`
 - `final public static function __xhpReflectionChildrenDeclaration(): nothing`
 - `final public static function __xhpReflectionCategoryDeclaration(): keyset<string>`
 - `protected function __xhpChildrenDeclaration(): mixed`
 - `public function __getChildrenDeclaration(): string`
 - `final public function __getChildrenDescription(): string`

All these threw an `\Error` (which is not caught by `catch (\Exception $e)`) since the release of sgml-stream. Their functionality will not be missed, but their removal may create typechecker errors in otherwise dead code.

---

## Deprecations and upgrading

The following six types have have been kept for backwards compatibility:

 - `ConcurrentSingleUseRenderer` (the `Renderer` interface is deprecated)
 - `AsynchronousUserElement`
 - `AsynchronousUserElementWithWritableFlow`
 - `DisposableUserElement`
 - `SimpleUserElement`
 - `SimpleUserElementWithWritableFlow`

These element types don't get access to `Init<Flow>` nor `Successor<Flow>`. Doing so would break backwards compatibility. There is a new variant of each element type available. `PrefixUserElementSuffix` can be replaced with `PrefixElementSuffix`.

If you use HHAST, you can run the migration found at [the sgml-stream github](https://github.com/hershel-theodore-layton/sgml-stream/blob/537a7dd956fc6946d5c4631ed311edafdbf7d912/tests/migrations). The output of this migration should be reviewed before committing the code. This migration upgrades `use type` clauses, `extends` clauses, adds a `use IgnoreSuccessorFlow` clause, it renames `compose()` / `composeAsync()`, and adds the `Flow $_init_flow` parameter.

You may have to manually change types from `Flow` to `Descendant<Flow>`, `Init<Flow>`, `Successor<Flow>` in your own code. A migration would not be able to infer how you are going to use this flow.

`Chameleon<Flow>` is a type which passes for `Descendant<Flow>`, `Init<Flow>`, and `Successor<Flow>`. All these flow types pass for their inner type. An `Init<Flow>` can be assigned to a `Flow`. A `Successor<WritableFlow>` can be assigned to a `WritableFlow`, etcetera.

If you don't want to deal with flow kinds, the function `SGMLStreamInterfaces\cast_to_chameleon__DO_NOT_USE()` can be used to force any flow kind back to `Chameleon<Flow>`.
