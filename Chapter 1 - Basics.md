---
id: d4sfo0y38c0zcrgf2su122n
title: Chapter 1 - Basics
desc: ''
updated: 1664092540732
created: 1664091783661
---
**Assignment**

`const` means immutable constant

`var` means mutable variable

`const constant: i32 = 5;` // signed 32-bit constant

`var variable: u32 = 5000;` // unsigned 32-bit variable

// @as performs an explicit type coercion

`const inferred_constant = @as(i32, 5);`

`var inferred_variable = @as(u32, 5000);`

Constants must have a value, else can use '`undefined` as long as type annotation is provided

`const a: i32 = undefined;`

`var b: u32 = undefined;`


