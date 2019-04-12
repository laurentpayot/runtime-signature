# :blossom: Floweret

[![Build Status](https://badgen.net/travis/laurentpayot/floweret)](https://travis-ci.org/laurentpayot/floweret)
[![Coverage Status](https://badgen.net/coveralls/c/github/laurentpayot/floweret)](https://coveralls.io/github/laurentpayot/floweret?branch=master)
[![npm dependencies](https://badgen.net/david/dep/laurentpayot/floweret)](https://david-dm.org/laurentpayot/floweret)
[![npm bundle size](https://badgen.net/bundlephobia/minzip/floweret)](https://bundlephobia.com/result?p=floweret)
[![npm version](https://badgen.net/npm/v/floweret)](https://www.npmjs.com/package/floweret)

## Why?

Either…

* You need type checking in the browser: external APIs, forms, etc.
* You are looking for a concise type syntax.
* You :heart: CoffeeScript but you miss a convenient type system for it.

*Floweret* is a JavasScript runtime type system that is:

* **Intuitive**: Native JavaScript types syntax.
* **Powerful**: Type composition, promises, rest parameters, logical operators and more…
* **Lightweight**: No dependencies. Typically [around 3 kB](#benchmark) minified and gzipped. Less if you use tree shaking. Concise syntax that does not bloat your code.
* **Fast**: Direct type comparison. No string to parse.
* **Customizable**: Create your own types for your own needs.

## Contents

* [Install](#install)
* [Usage](#usage)
  * [JavaScript](#javascript)
  * [CoffeeScript](#coffeescript)
* [Variable typing](#check)
* [Function typing](#fn)
  * [Absence of type](#absence-of-type)
  * [Maybe type](#maybe-type)
  * [Promised type](#promised-type)
  * [Rest arguments type](#rest-arguments-type)
  * [Any type](#any-type)
  * [Unchecked type](#any-type)
* [Basic types](#basic-types)
  * [Native types](#native-types)
  * [Literal type](#literal-type)
  * [Regular expression type](#regular-expression-type)
  * [Union of types](#union-of-types)
  * [Typed array type](#typed-array-type)
  * [Sized array type](#sized-array-type)
  * [Object type](#object-type)
  * [Class type](#class-type)
* [Advanced types](#advanced-types)
  * [Tuple](#tuple)
  * [Typed Object](#typed-object)
  * [Typed Set](#typed-set)
  * [Typed Map](#typed-map)
  * [Integer](#integer)
  * [Sized string](#sized-string)
  * [Logical operators](#logical-operators)
    * [Or](#or)
    * [And](#and)
    * [Not](#not)
  * [Foreign types](#foreign-types)
  * [Constraint type](#constraint-type)
  * [Custom types](#custom-types)
* [Type composition](#type-composition)
* [Tools](#tools)
  * [isValid](#isvalid)
  * [typeOf](#typeof)
* [Benchmark](#benchmark)
* [License](#license)

## Install

```bash
$ npm install floweret
```

or

```bash
$ yarn add floweret
```

## Usage

> fn( <argument 1 type\>, <argument 2 type\>, …, <argument n type\>, <result type\>, <function\> )

> <variable\> = check(<type\>)

To add a signature to a function, wrap the function with the `fn` function.
`fn` arguments are first the list of arguments types, followed by the result type, and finally the function itself:

### JavaScript

```js
import { fn } from 'floweret'

const MethodType = ['GET', 'POST', 'PUT', 'DELETE']

const add = fn(
  Number, Number, Number,
  function (a, b) {return a + b}
)
```

or using the ES2015 arrow function syntax:

```js
import { fn } from 'floweret'

const add = fn(
  Number, Number, Number,
  (a, b) => a + b
)
```

Note that `fn` could be used as a decorator, but sadly [JavaScript decorators proposal](https://github.com/tc39/proposal-decorators) does not support standalone functions…
For readability, most examples below will use the ES2015 arrow function syntax.

### CoffeeScript

You can ommit the `fn` parentheses, resulting in a decorator-like syntax:

```coffee
import { fn } from 'floweret'

add = fn Number, Number, Number,
  (a, b) -> a + b
```

The following [CoffeeScript's type annotations example](https://coffeescript.org/#type-annotations) (that needs [Flow](https://flow.org/) in the background)

```coffee
# @flow

###::
type Obj = {
  num: number,
};
###

f = (str ###: string ###, obj ###: Obj ###) ###: string ### ->
  str + obj.num
```

can be rewritten with less "noise":

```coffee
import { fn } from 'floweret'

Obj =
  num: Number

f = fn String, Obj, String,
  (str, obj) ->
    str + obj.num
```

Another example showing Floweret usage with CoffeeScript:

```coffee
import { fn, maybe } from 'floweret'

# union of valid string litterals
MethodType = ['GET', 'POST', 'PUT', 'DELETE']

# object attribute types
InfoType =
  size: Number
  title: String

#    arg. #1 type ⮢       ⮣ arg. #2 type (optional)    ⮣ result type (promise of an InfoType object)
getPageInfo = fn String, maybe(MethodType), Promise.resolve(InfoType),
  (url, method) ->
    # `url` and `method` arguments are now typed inside this function: `url = 1` would throw a TypeError
    response = await fetch(url, {method})
    html = await response.text()
    size: html.length
    title: /<title>([^<]+)/.exec(html)[1]

# {size: 201972, title: "laurentpayot/floweret: An easy JavaScript runtime type system."}
currentPageInfo = await getPageInfo('.')

# the result is typed as InfoType
currentPageInfo.size = "foo" # TypeError: …

getPageInfo() # TypeError: …
getPageInfo(1) # TypeError: …
getPageInfo(1, 'FOO') # TypeError: …
```

## Types

### Native types

> <native type\>

All native JavaScript type constructors are allowed as type:
`Number`, `String`, `Array`, `Object`, `Boolean`, `RegExp`, `undefined`, `null`, `Promise`, `Function`, `Set`, `Map`, `WeakMap`, `WeakSet`, etc.

```js
const f = fn(
  Number, String, Array,
  (a, b) => [a, b]
)

f(1, 'a') // [1, 'a']
f(1, 5)   // TypeError: Argument #2 should be of type 'String' instead of Number 5.
```

### Absence of type

When the function takes no argument, only the result type is needed:

```js
const returnHi = fn(
  String,
  function () {return "Hi"}
)

returnHi()  // Hi
returnHi(1) // TypeError: Too many arguments provided.
```

Use `undefined` as the result type when the function returns nothing (undefined):

```js
const logInfo = fn(
  String, undefined,
  function (msg) {console.log("Info:", msg)}
)

logInfo("Boo.") // logs "Info: Boo.", returns undefined

const logHi = fn(
  undefined,
  function () {console.log("Hi")}
)

logHi() // logs "Hi", returns undefined
```

### Union of types

> [ <type 1\>, <type 2\>, …, <type n\> ]

You can create a type that is the union of several types. Simply put them between brackets.
For instance the type `[Number, String]` will accept a number or a string.

```js
const f = fn(
  Number, [Number, String], String,
  (a, b) => '' + a + b
)

f(1, 2)    // '12'
f(1, '2')  // '12'
f(1, true) // TypeError: Argument #2 should be of type 'Number or String' instead of Boolean true.
```

### Maybe type

> maybe( <type\> )

Usefull for optional parameters of a function. This is simply a shortcut to the union `[undefined, <type>]`.

* **:warning:** Unlike [Flow's maybe types](https://flow.org/en/docs/types/maybe/), a `null` value will generate an error, as it should.

```js
import { fn, maybe } from 'floweret'

const f = fn(
  Number, maybe(Number), Number,
  (a, b=0) => a + b
)

f(5)       // 5
f(5, 1)    // 6
f(5, '1')  // TypeError: Argument #2  should be of type 'undefined or Number' instead of String "1".
f(5, null) // TypeError: Argument #2 should be of type 'undefined or Number' instead of null.
```

### Literal type

> <string or number or boolean or undefined or null or NaN\>

A literal can only be a string, a number, a boolean or be equal to `undefined` or `null` or `NaN`. Literals are useful when used inside an union list.

```js
const turn = fn(
  ['left', 'right'], String,
  (direction) => "turning " + direction
)

turn('left')  // "turning left"
turn('light') // TypeError: Argument #1 should be of type 'literal String "left" or literal String "right"' instead of String "light".
```

### Regular Expression type

> <regular expression\>

When the type is a regular expression, if the value is a string it will be tested to see if it matches the regular expression.

```js
const Email = /\S+@\S+\.\S+/ // simple email RegExp, do not use in production

const showEmail = fn(
  Email, String, String, undefined,
  (email, subject, content) => console.table({ email, subject, content })
)

// nice email display
showEmail('laurent@example.com', "Hi", "Hello!")

// TypeError: Argument #1 should be of type 'string matching regular expression /\S+@\S+\.\S+/' instead of String "laurent.example.com".
showEmail('laurent.example.com', "Hi", "Hello!")
```

* **:warning:** Regular expressions are slow so if you need to check a lot of data consider using a [constraint type](#constraint-type) with String prototype methods instead.

### Typed array type

> Array(<type\>)

You can use the `Array` constructor type for arrays with elements of any type, but most of the time it is better to specify the type of the elements.

If you want to specify the type of the elements of an array, use this type as the `Array` constructor argument. For instance simply use `Array(String)` for an array of strings:

```js
const dashJoin = fn(
  Array(String), String,
  (strings) => strings.join('-')
)

dashJoin(["a", "b", "c"]) // a-b-c
dashJoin(["a", "b", 3])   // TypeError: Argument #1 should be an array with element 2 of type 'String' instead of Number 3.
```

* **:warning:** If you want an array with elements of a type that is the union of severay types, do not forget the brackets (`[` and `]`).
  * Use `Array([Number, String])` to accept an array of elements that can be numbers or strings, such as `[1, "2", 3]`.
  * If you forget the brackets you will get the union of types instead of the array of union of types, because in JavaScript `Array(Number, String)` is the same as `[Number, String]`.

### Sized array type

> Array(<length\>)

If you want to specify the length of an array, use this length as the `Array` constructor argument.

For instance use `Array(5)` for an array of five elements:

```js
const pokerHand = fn(
  Array(5), String,
  (cards) => cards.join('-')
)

pokerHand([7, 9, "Q", "K", 1])     // 7-9-Q-K-1
pokerHand([7, 9, 10, "Q", "K", 1]) // TypeError: Argument #1 should be an array with a length of 5 instead of 6.
```

Sized array type is useful when used in conjunction with a typed array type, thanks to the [`and` operator](#and).
Note that you can use the empty array `[]` for an array of size 0 type, if you ever need it.

### Object type

> {<key 1\>: <type 1\>, <key 2\>: <type 2\>, …, <key n\>: <type n\>}

You can specify the types of an object values, at any depth.

```js
const userType = {
  id: Number,
  name: {
    first: String,
    last: String,
    middle: [String, undefined]
  }
}

const fullName = fn(
  userType, String,
  (user) => Object.keys(user.name).join(' ')
)

let Bob = {
  id: 1234,
  name: {
    first: "Robert",
    last: "Smith"
  }
}

// "Robert Smith"
fullName(Bob)

// TypeError: Argument #1 should be an object with key 'name.first' of type 'String' instead of Number 1.
fullName({id: 1234, name: {first: 1, last: "Smith"}})
```

* **:warning:** If values of an object argument match all the keys types of the object type, **the argument will be accepted even if it has more keys than the object type** (except if type is the empty object `{}`):

```js
const f = fn(
  {a: Boolean, b: {x: Number, y: Number}}, Number,
  (obj) => obj.b.x + obj.b.y
)

f({a: true, b: {x: 1, y: 2}}) // 3
f({a: true, b: {x: 1, y: 2}, foo: "bar"}) // 3 (no error)
f({a: true, b: {x: 1, z: 2}}) // TypeError: Argument #1 should be an object with key 'b.y' of type 'Number' instead of missing key 'y'.
f({a: true, b: {x: 1, y: undefined}}) // TypeError: Argument #1 should be an object with key 'b.y' of type 'Number' instead of undefined.
```

### Class type

> <class\>

Simply use the class itself as the type:

```js
class Rectangle {
  constructor(height, width) {
    this.height = height;
    this.width = width;
  }
}

// Of course it would be better to have superficy() as a Rectangle method,
// but that is not the point…
const superficy = fn(
  Rectangle, Number,
  (rect) => rect.height * rect.width
)

let myRect = new Rectangle(10, 5)

superficy(myRect) // 50
superficy("foo") // TypeError: Argument #1 should be of type 'Rectangle' instead of String "foo".
superficy({height: 10, width: 5}) // TypeError: Argument #1 should be of type 'Rectangle' instead of Object.
```

### Promised type

> Promise.resolve(<type\>)

or with the `promised` shortcut:

> import promised from 'floweret/types/promised'
>
> promised(<type\>)

Promised types are used for the *result* type of the function signature.

You can use the `Promise` result type when a function returns a promise that can be of any type, but most of the time it is better to specify the type of the resolved value.

For instance use the `Promise.resolve([Object, null])` type for a promise that will resolve with an object or the null value:

```js
const getUserById = fn(
  Number, Promise.resolve([Object, null]),
  function (id) {
    return new Promise(resolve => {
      // simulating slow database/network access
      setTimeout(() => id ? resolve({id, name: "Bob"}) : resolve("anonymous"), 1000)
    })
  }
)

await getUserById(1234) // {id: 1234, name: "Bob"}
await getUserById(0) // TypeError: Result should be a promise of type 'Object or null' instead of String "anonymous".
```

### Any type

> Any

Use the `Any` type when a parameter or a result can be of any type:

```js
import { fn, Any } from 'floweret'

const log = fn(
  Any, undefined,
  (x) => console.log(x)
)

log("foo") // logs "foo"
log({a: 1, b: 2}) // logs Object {a: 1, b: 2}
```

### Rest arguments type

> etc(<type\>)

or (untyped)

> etc

```js
import { fn, etc } from 'floweret'

const average = fn(
  etc(Number), [Number, NaN], // for Floweret NaN is NOT a Number (unlike JavaScript)
  (...numbers) => numbers.reduce((acc, curr) => acc + curr, 0) / numbers.length
)

average()           // NaN (0/0)
average(2, 6, 4)    // 4
average([2, 6, 4])  // TypeError: Argument #1 should be of type 'Number' instead of Array.
average(2, true, 4) // TypeError: Argument #2 should be of type 'Number' instead of Boolean true.
```

* **:warning:** Rest type can only be the last type of the signature arguments types, [as it should be in JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters#Description).
* **:coffee:** CoffeeScript doesn't have this limitation, but this neat CoffeeScript feature is not implemented (yet) in floweret.

### Logical operators

#### Or

> or( <type 1\>, <type 2\>, …, <type n\> )

`or` is the same as the [union of types](#union-of-types) brackets notation, but more explicit.

```js
import { fn } from 'floweret'
import or from 'floweret/types/or'

const size = fn(
  or(String, Array), Number,
  (x) => x.length
)

size("ab")       // 2
size(['a', 'b']) // 2
size({a: 'b'})   // TypeError: Argument #1 should be of type 'String or Array' instead of Object.
```

* **:coffee:** `or` is a reserved CoffeeScript word. Use another identifier for imports in your CoffeeScript file:

  ```coffee
  # CoffeeScript
  import Or from 'floweret/types/or'
  ```

#### And

> and( <type 1\>, <type 2\>, …, <type n\> )

`and` is for intersection of types. It is useful with constraints or to specify typed arrays of a given length:

```js
import { fn } from 'floweret'
import and from 'floweret/types/and'

const weeklyMax = fn(
  and(Array(Number), Array(7)), Number,
  (days) => Math.max(...days)
)

weeklyMax([1, 1, 2, 2, 5, 5, 1]) // 5
weeklyMax([1, 1, 2, 2, 5, 5]) // TypeError: Argument #1 should be of type ''array of 'Number'' and 'array of 7 elements'' instead of Array.
```

* **:coffee:** `and` is a reserved CoffeeScript word. Use another identifier for imports in your CoffeeScript file:

  ```coffee
  # CoffeeScript
  import And from 'floweret/types/and'
  ```

#### Not

> not( <type\> )

`not` is the the complement type, i. e. for items not matching the type:

```js
import { fn } from 'floweret'
import not from 'floweret/types/not'

const getConstructor = fn(
  not([undefined, null]), Function,
  (x) => x.constructor
)

getConstructor(1)    // function Number()
getConstructor(null) // TypeError: Argument #1 should be of type 'not 'undefined or null'' instead of null.
```

* **:coffee:** `not` is a reserved CoffeeScript word. Use another identifier for imports in your CoffeeScript file:

  ```coffee
  # CoffeeScript
  import Not from 'floweret/types/not'
  ```

### Constraint type

> constraint(<function\>)

You can quickly create new types using the `constraint` type, that takes a validation function as argument:

```js
import { fn } from 'floweret'
import constraint from 'floweret/types/constraint'

const Int = constraint(val => Number.isInteger(val))

const f = fn(
  Int, String,
  n => n + "eggs needed for that recipe"
)

f(2)   // "2 eggs needed for that recipe"
f(2.5) // TypeError: Argument #1 should be of type 'constrained by 'val => Number.isInteger(val)'' instead of Number 2.5.
```

If you need more complex types have a look in the [Floweret-included types](#included-types) or create you own [custom types](#custom-types).

### Included types

#### Tuple

> Tuple( <type 1\>, <type 2\>, …, <type n\> )

```js
import { fn } from 'floweret'
import Tuple from 'floweret/types/Tuple'

const Coords = Tuple(Number, Number, Number) // latitude, longitude, altitude

const getLongitude = fn(
  Coords, Number,
  (c) => c[1]
)

getLongitude([10, 20, 5])   // 20
getLongitude([10, 5])       // TypeError: Argument #1 should be of type 'tuple of 3 elements 'Number, Number, Number'' instead of Array.
getLongitude([10, 20, '5']) // TypeError: Argument #1 should be of type 'tuple of 3 elements 'Number, Number, Number'' instead of Array.
```

#### Typed Object

> TypedObject(<values type\>)

Typed object types are useful for object types with values of a given type.
Key type is always `String`, just like normal objects.

```js
import { fn } from 'floweret'
import TypedObject from 'floweret/types/TypedObject'

const Results = TypedObject(Number)

const maxGrade = fn(
  Results, Number,
  (results) => Math.max(...Object.values(results))
)

maxGrade({
    Alice: 8.5,
    Larry: 8,
    Bob: 9.1
}) // 9.1

maxGrade({
    Alice: 8.5,
    Larry: "B",
    Bob: 9.1
}) // TypeError: Argument #1 should be of type 'object with values of type 'Number'' instead of Object.
```

#### Typed Set

> TypedSet(<elements type\>)

```js
import { fn } from 'floweret'
import TypedSet from 'floweret/types/TypedSet'

const isSalty = fn(
  TypedSet(String), Boolean,
  (ingredients) => [...ingredients].includes('salt')
)

isSalty(new Set(["chocolate", "salt", "banana"])) // true
isSalty(new Set(["chocolate", "salt", 100])) // TypeError: Argument #1 should be of type 'set of 'String'' instead of Set.
```

#### Typed Map

> TypedMap(<values type\>)

or

> TypedMap(<keys type\>, <values type\>)

*Documentation in progress…*

#### Integer

> Integer

or

> Integer(<maximum value\>)

or

> Integer(<minimum value\>, <maximum value\>)

* Use `Integer` with two arguments to specify values range for an integer number.
* If only one argument is provided, it is considered as the maximum value, the minimum value being 0. Thus use `Integer(Number.MAX_SAFE_INTEGER)` for positive integers including 0.
* Used without argument, `Integer` simply specify an integer number, positive or negative.

```js
import { fn } from 'floweret'
import Integer from 'floweret/types/Integer'

const Temperature = Integer(-70, 70)

const maxTemperature = fn(
  Array(Temperature), Temperature,
  (temperatures) => Math.max(...temperatures)
)

maxTemperature([5, -2, 20, 17]) // 20
// TypeError: Argument #1 should be an array with element 3 of type 'Integer
// bigger than or equal to -70 and smaller than or equal to 70' instead of Number 170.
maxTemperature([5, -2, 20, 170])
```

#### Sized string

> SizedString(<maximum length\>)

or

> SizedString(<minimum length\>, <maximum length\>)

*Documentation in progress…*

### Foreign types

> foreign(<foreign type name\>)

or

> foreign(<object type\>)

Sometimes when you use external libraries you have to handle instances whithout having access to their classes definitions. You can use the `foreign` operator to check that the instance constructor is of the expected type.

Here is a Firebase example where we wrap the [createUser](https://firebase.google.com/docs/reference/admin/node/admin.auth.Auth#createUser)
function that returns a promise of a *Firebase-defined* `UserRecord` instance:

```js
import { fn } from 'floweret'
import foreign from 'floweret/types/foreign'

import * as admin from 'firebase-admin'
admin.initializeApp(/* your Firebase config */)

export createUser = fn(
  Object, Promise.resolve(foreign('UserRecord')),
  (data) => admin.auth().createUser(data)
            .catch((err) => console.error("User Creation:", err.message))
)
```

Sometimes you cannot use the foreign class name because it has been mangled by a minifier and is subject to change. In such a case you can use the `foreign` operator with an [Object type](#object-type) argument to do some *duck typing* with some (not necessarily all) properties of the foreign type instance.
The above example could end with:

```js
const UserRecord = foreign({
    uid: String,
    emailVerified: Boolean,
    disabled: Boolean
  })

export createUser = fn(
  Object, Promise.resolve(UserRecord),
  (data) => admin.auth().createUser(data)
            .catch((err) => console.error("User Creation:", err.message))
)
```

### Custom types

*Documentation in progress…*

## Type composition

As types are simply JavaScript expressions, you can assign any type to a variable and use it to create new types:

```js
const Phone = [Number, undefined]
const Name = {first: String, last: String, middle: [String, undefined]}
const User = {id: Number, name: Name, phone: Phone}
```

## Tools

Some handy utilities exported by the package.

### isValid

> isValid(<value\>, <type\>)

`isValid` can tell if a value is of a given type. Useful for user input validation:

```js
import { isValid } from 'floweret'

isValid("abc", [Number, String]) // true
```

### typeOf

> typeOf(<value\>)

The `typeOf` function is a replacement of the standard JavaScript `typeof` operator:

```js
import { typeOf } from 'floweret'

// standard JavaScript `typeof` operator
typeof [1, 2] // 'object'
typeof Promise.resolve(1) // 'object'
typeof NaN // 'number'

// more usefull results
typeOf([1, 2]) // 'Array'
typeOf(Promise.resolve(1)) // 'Promise'
typeOf(NaN) // 'NaN'
```

## Benchmark

Run the benchmark with:

```shell
npm run benchmark
```

The benchmark currently includes the folowing runtime type-checking systems:

* **no type-checking**: the reference results.
* [**Floweret**](https://github.com/laurentpayot/floweret): you might know it if you are reading this.
* [**Runtypes**](https://github.com/pelotom/runtypes): "Runtime validation for static types" (TypeScript-oriented)
* [**Object Model**](https://github.com/sylvainpolletvillard/ObjectModel): "Strong Dynamically Typed Object Modeling for JavaScript."
* [**Flow-runtime**](https://codemix.github.io/flow-runtime): "Flow-compatible runtime type system for JavaScript."

The [sub-benchmarks](https://github.com/laurentpayot/floweret/tree/master/benchmark) are run from minified [Rollup](https://rollupjs.org) bundles (UMD) and call two simple functions several thousand times.

Here are some results from my Ubuntu machine with node v11.10.1:

```txt
no-type-checking-benchmark.min.js.gz  257 bytes
floweret-benchmark.min.js.gz          3415 bytes
objectmodel.min.js.gz                 4123 bytes
runtypes.min.js.gz                    6036 bytes
flow-runtime-benchmark.min.js.gz      20240 bytes


*** No type-checking ***
10000 greets: 2.101ms
10000 sums: 25.062ms

*** Floweret ***
10000 greets: 36.680ms
10000 sums: 304.042ms

*** Runtypes ***
10000 greets: 12.668ms
10000 sums: 36.834ms

*** Object Model ***
10000 greets: 131.840ms
10000 sums: 936.078ms

*** Flow-runtime ***
10000 greets: 293.982ms
10000 sums: 499.800ms
```

Feel free to make your own benchmarks and share the results.

## License

[MIT](https://choosealicense.com/licenses/mit/)
