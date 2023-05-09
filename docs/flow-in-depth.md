# Flow in depth

## Constants and variables

This Flow acts like a scope. You can `->assignVariable(string $name, mixed $value): void` in your scope. You and all your sub scopes can read this variable. The first time when you assign a variable in your scope, it is automatically declared. It behaves like variable assignment in python would. If you write to the same variable in a sub scope, you are [shadowing](https://en.wikipedia.org/wiki/Variable_shadowing) this original `$name`.

```PY
def outer_scope():
  a = 1
  def inner_scope():
    a = 2
    print(a) # prints 2
  inner_scope()
  print(a) # prints 1

outer_scope()
```

If you know a value will never been set again once it has been set, you can use `->declareConstant()` instead of `->assignVariable()`. If the constant is a mutable object, you will still be able to modify the object after declaring the constant. You just won't be able to change which object the constant holds. `->declareConstant()` can only be called once with a given `$name` in a scope. If you call `->declareConstant("a", 1)`, `->declareConstant("a", 2)` a `RedeclaredConstantException` will be thrown. You can not shadow a constant. Once an ancestor has declared the constant `"a"`, you can not redeclare it. `->declareConstant("a", 3)` would fail immediately. It behaves very much like `val` in Kotlin, provided you treat shadowing warnings as errors.

```KOTLIN
fun main() {
  val a = 1;
  if (true) {
    val a = 3; // disallowed
  }
  a = 2; // disallowed
}

fun main() {
  if (true) {
    val a = 1; // ok
    print(a); // prints 1
  }
  
  if (true) {
    val a = 2; // ok
    print(a); // prints 2
  }
}
```

Let's illustrate with an example:

```HTML
<MyHtml id="a" data-comment="I declare const C1 and assign variable V1">
  <MyHead id="b" data-comment="I declare const C2"><MyLink id="c" rel="stylesheet" src="..." /></MyHead>
  <MyBody id="d" data-comment="I also declare const C2, but with a different value">
    <MyElement id="e" data-comment="I assign variable V1 with a new value">
      <MyNestedElement id="f" />
    </MyElement>
    <MyElement id="g">
      <MyNestedElement id="h" />
    </MyElement>
  </MyBody>
</MyHtml>
```

Element `a` declared the constant `C1`. After this `->declareConstant()` call, anyone can call `Flow->getx('C1')` and read the value that `a` declared. `C1` is visible to `a`, `b`, `c`, `d`, `e`, `f`, `g`, and `h`. Any call made to `->assignVariable('C1', ...)` or `->declareConstant('C1', ...)` will throw.

Element `a` also assigns the variable `V1`. This means that the variable "goes out of scope" when `a` and all its descendants have been rendered. `V1` is visible to `a`, `b`, `c`, `d`, `e`, `f`, `g` and `h`. They can assign a different value to `V1`, like `g` does. However from any of these scopes, `->declareConstant('V1', ...)` will throw.

Element `b` declared the constant `C2`. The same rules as in the `C1` example apply. The value `b` declared is only visible to `b` and `c`. This is also why `d` was allowed to declare `C2` "again". It could never see `b`'s declaration, so from its scope, the name `C2` is still available.

Element `e` assigns the variable `V1`. This shadows the `V1` from `a`. `g` and `h` will not observe the new value from `e`. They will observe the value from `a`.

Element `g` assigns a value to `V1`. This variable has been assigned by `a` before. This means that `g`'s assignment is shadowing `a`'s. This means that `g` and `h` can read the value assigned by `g`, but all other elements read the value assigned by `a`. Even if their read happens after `g`'s write.
