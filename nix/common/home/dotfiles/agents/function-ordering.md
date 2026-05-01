# Function ordering for readability

As codebases grow, unorganized files become difficult to grok and slow down
onboarding. Order functions according to the call tree.

## Rule 1: Functions should be laid out using the "function call tree"

Think of a file as a tree. Root nodes are entrypoints (exports, public
functions, mains). They call child functions, which may call others, and so on.
Also applies in a class (public methods).

Functions should be grouped with the functions they call. A function should
always be defined before its leaf/branch functions (standard call-tree
ordering).

Here's a toy example. This code:

```js
import { D } from 'wherever'

function A() { B(); C(); }
function B() { D(); B2(); }
function B2() {}
function C() {}
function E() {}
```

Could be loosely represented as this tree:

```
myfile.js
├─ A
│  ├─ B
│  │  └─ B2
│  └─ C
├─ E
```

Note: `D` is imported, so it's not part of this file's ordering.

Functions should always be ordered according to the function call tree.

A function should always be grouped with its leafs, and should be defined
before any of its branch/leaf functions. If a branch has its own branches (like
in the case of `B()` calling `B2()` above) it should be defined before the next
branch — `B2()` should be defined before `C()`.

## Rule 2: Functions of the same tree depth should be sorted in call order

This rule was implied above.

Functions that are the same depth should be sorted in the order that they are
called. The above definition would be invalid if `C()` was defined before
`B2()`:

```js
import { D } from 'wherever'

function A() { B(); C(); }
// ❌ Bad: C() should be after B()'s subtree because B is called before C
function C() {}
function B() { D(); B2(); }
function B2() {}
function E() {}
```

## Rule 3: Functions shared in multiple places are their own root nodes

Functions used by multiple other functions should become their own root nodes.
Sort them after they are called.

```js
function A() { C(); }
function B() { C(); }
function C() {}
```

The function call tree would be flat, because they are all root nodes:

```
myfile.js
├─ A
├─ B
├─ C
```

> Source: https://www.staycaffeinated.com/2021/05/15/coding-standards-function-ordering
> Changes: marked `D()` as imported and added `B2()` as a local helper of `B()`
