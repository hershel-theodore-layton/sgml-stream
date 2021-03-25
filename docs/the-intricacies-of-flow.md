# The intricacies of Flow

## Constants and variables

This Flow acts like a scope. Think of [let](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/let) and [const](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/const) in javascript. You can `->assignVariable(string $name, mixed $value): void` in your scope. You and all your children (sub scopes) can read this variable. The first time when you assign a variable in your scope, it is automatically declared. It behaves like `let $name = $value` would in javascript (mostly). If you assign to this variable again within the same scope, this does not error. It is as if the `let` keyword is removed for all writes in the same scope, after the first. If you write to the same variable in a sub scope, you are [shadowing](https://en.wikipedia.org/wiki/Variable_shadowing) this original `$name`. You can not shadow a constant. If a constant with `$name` already exists in your scope or a parent scope, a `RedeclaredConstantException` will be thrown.

Most values do not change after they have been set. Flow does offer `WritableFlow->declareConstant(string $name, mixed $value): void` for this use case. This behaves like `const $name = $value` would in javascript (mostly). You can not change the value of a constant after it has been declared. If the value itself is mutable (like an object), you can still modify the object. You can not declare a constant with `$name` again in the same scope or sub scopes. Shadowing constants can not be done. You are also banned from declaring a constant if a variable with that `$name` already exists.

Let's illustrate with an example:

```HTML
<MyHtml id="a" data-comment="I declare const C1 and assign variable V1">
  <MyHead id="b" data-comment="I declare const C2"><MyLink id="c" rel="stylesheet" src="..." /></MyHead>
  <MyBody id="d" data-comment="I also declare const C2, but with a different value">
    <MyElement id="e" data-comment="I assign variable V2">
      <MyNestedElement id="f" />
    </MyElement>
    <MyElement id="g" data-comment="I assign variable V1 with a new value">
      <MyNestedElement id="h" />
    </MyElement>
  </MyBody>
</MyHtml>
```

Element `a` declared the constant `C1`. After this `->declareConstant()` call, anyone can call `Flow->getx('C1')` and read the value that `a` declared. `C1` is visible to `a`, `b`, `c`, `d`, `e`, `f`, `g`, and `h`. Any call made to `->assignVariable('C1', ...)` or `->declareConstant('C1', ...)` will throw.

Element `a` also assigns the variable `V1`. This was the first time that `V1` was seen in this scope, so this is implicitly a `let` statement. This means that the variable "goes out of scope" when `a` and all its children have been rendered. `V1` is visible to `a`, `b`, `c`, `d`, `e`, `f`, `g` and `h`. They can assign a different value to `V1`, like `g` does. However from any of these scopes, `->declareConstant('V1', ...)` will throw.

Element `b` declared the constant `C2`. The same rules as in the `C1` example apply. The value `b` declared is only visible to `b` and `c`. This is also why `d` was allowed to declare `C2` "again". It could never see `b`'s declaration, so from its scope, the name `C2` is still available.

Element `e` assigns the variable `V2`. The same rules as in the `V1` case apply. The value `e` assigned is only visible to `e`and `f`. Any other element calling `->getx('V2', ...)` would throw. Since from their scope, `V2` never existed.

Element `g` assigns a value to `V1`. This variable has been assigned by `a` before. This means that `g`'s assignment is shadowing `a`'s. This means that `g` and `h` can read the value assigned by `g`, but all other elements read the value assigned by `a`. Even if their read happens after `g`'s write.
