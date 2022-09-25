---
id: xl3417fvsel22klk8hjuuv1
title: Step-1-Hello-World
desc: ''
updated: 1664085643135
created: 1664079702389
---

---
created: 2022-09-25T09:51:49 (UTC +05:30)
tags: []
source: https://ziglearn.org/
author: 
---

# Chapter 0 - Getting Started | ziglearn.org

> ## Excerpt
> Ziglearn - A Guide / Tutorial for the Zig programming language. Install and get started with ziglang here.

---
# Hello World [#](https://ziglearn.org//#hello-world)

Create a file called `main.zig`, with the following contents:

```zig
const std = @import("std");

pub fn main() void {
    std.debug.print("Hello, {s}!\n", .{"World"});
}
```

###### (note: make sure your file is using spaces for indentation, LF line endings and UTF-8 encoding!) [#](https://ziglearn.org//

#note-make-sure-your-file-is-using-spaces-for-indentation-lf-line-endings-and-utf-8-encoding)

Use `zig run main.zig` to build and run it. 

In this example `Hello, World!` will be written to stderr, and is assumed to never fail.

