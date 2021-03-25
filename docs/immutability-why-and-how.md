# Immutability, why and how?

## Why is ->setAttribute() gone?

One (compound) word, type safety. `->setAttribute(string $attr, mixed $value): void` bypasses the typechecker and makes your attribute definitions a lie. If your class looks like this:
```HACK
final xhp class ex extends ... {
  attribute string str @required;
}
```

Then this look like this to the typechecker:
```HACK
// pseudo syntax
final xhp class ex extends ... {
  readonly public string $:str;
}
```

Both xhp-lib and sgml-stream try _really hard_ to make your object behave like this. When you write `$ex->:str` you are not reading from a "real" property. Your code gets rewritten into this. `$ex->getAttribute('str')`. `->getAttribute(string $attr): mixed` returns mixed, but the typechecker ignores that fact. With `->setAttribute()` in play, you can make `$ex->:str` not a string. This code typechecks `$ex->setAttribute('str', 1); Str\length($ex->:str);`, but at runtime, this is a type violation. We can not offer an API for setting attributes with hhvm and Hack as it is today. If Hack or hhvm evolves to address this issue, we'd gladly follow in xhp-lib's footsteps.

## Why is ->appendChild() gone?

When we were using xhp-lib, `->appendChild()` got overused. The code became hard to read. We often took the time compact an xhp code path. Using `<div>{ $xhp_expression }</div>` we were able to remove many `->appendChild()` calls. We still use `->appendChild()`, but we've made it more inconvenient for ourselves. If we want to append to something, and it is in local scope, and it is a great benefit to code clarity, we do this.

```HACK
$append = <append />;
$my_element = <MyElement>...{$append}</MyElement>;
// A lot of complex code follows, that would not
// be well suited for an ` { ... } ` expression.
$append->appendChild(...);
```

The name `<append />` makes it blindingly obvious that this element is going to have dynamic children set later. We let `$append` fall out of scope at the end of the function. If `$append` is handed away, we consider this to be bad practice.

The `<append>` tag is no rocket science. It keeps a vec of `XHPChild` internally and streams them when asked. If you are migrating from xhp-lib to sgml-stream, this class can help migrate older code that can't easily be rewritten without it `->appendChild()`.

## Possible changes to sgml-stream

If external users really want mutability back, we could conditionally define these methods depending on the `this` type. This would be an avenue worth exploring if need be.

```HACK
interface EnableMethodAppendChild {}

abstract class RootElement_ {
  public function appendChild(
    \XHPChild $child,
  ): this where this as EnableMethodAppendChild {
    // ...
    return $this;
  }
}

function foo(No $no, Yes $with): void {
  // Typing[4323] A where type constraint is violated here [1]
  // -> This is the method with where type constraints [2]
  // -> Expected EnableMethodAppendChild [3]
  // -> But got No [4]
  // ->   via this generic this [5]
  $no->appendChild('');
  // Okay
  $with->appendChild('');
}

final xhp class No extends RootElement_ {}

final xhp class Yes extends RootElement_ implements EnableMethodAppendChild {}

```