---
id: eb38w9y0g60zrhn6upj2vn5
title: When a var really isnt a var ft String Literals
desc: ''
updated: 1664097565704
created: 1664097549496
---
[When a var really isn't a var (ft. String Literals)](https://zig.news/gowind/when-a-var-really-isnt-a-var-ft-string-literals-1hn7)

---
created: 2022-09-25T14:49:41 (UTC +05:30)
tags: [ziglang,zig,howto,tutorial,learn]
source: https://zig.news/gowind/but-will-this-blowup--2j5m
author: 
created with: MarkDownload - Markdown Web Clipper
---

# When a var really isn't a var (ft. String Literals) - Zig NEWS ⚡

> ## Excerpt
> Read the latest happenings in the global Zig community.

---
[Govind](https://zig.news/gowind)

Posted on 24 Jun

# When a var really isn't a var (ft. String Literals)

[#arrays](https://zig.news/t/arrays) [#learn](https://zig.news/t/learn) [#beginners](https://zig.news/t/beginners) [#pointers](https://zig.news/t/pointers)

This post was inspired by this [thread](https://discord.com/channels/605571803288698900/719644313348341760/989299209574449162) and my frustrations with the notoriously sparse Zig documentation (Rant towards the end)

Imagine a contrived function, that sets every alternative character in a string to `a`. We don't know (and don't care) about how our String is created, just that it is X chars long and each char as an `u8`. Fortunately, there is a perfect type that satisfies our needs : A `slice`.  
Our function therefore takes a `slice` as input.  

```
fn alternate_a(input: []u8) void {
    var i: usize = 0;
    while(i < input.len): (i += 2) {
        input[i] = 'a';
    }
}
```

Enter fullscreen mode Exit fullscreen mode

Now you try to call this from `main`  

```
const std = @import("std");

pub fn main() void {
    const input = "Hello Zig";
    alternate_a(input);
    std.debug.print("Updated string is {s}\n", .{input});
}
```

Enter fullscreen mode Exit fullscreen mode

What happens ? Kaboom! You run into the first error !  

```
./src/main5.zig:12:17: error: expected type '[]u8', found '*const [9:0]u8'
    alternate_a(input);
```

Enter fullscreen mode Exit fullscreen mode

You think, okay, perhaps its because I have declared `input` as a `const`. No worries, let me change it to `var` (`var input = "Hello Zig";`)  

```
./src/main5.zig:12:17: error: expected type '[]u8', found '*const [9:0]u8'
    alternate_a(input);
```

Enter fullscreen mode Exit fullscreen mode

WTH ? It still shows the same error !

You wonder:

> Shouldn't `var` make things mutable (or atleast, shouldn't the compiler complain if you try to make a `var` point to a string-literal that isn't mutable ?)

Let us look at the documentation for string-literals

> String literals are constant single-item [Pointers](https://ziglang.org/documentation/0.9.1/#Pointers) to null-terminated byte arrays. The type of string literals encodes both the length, and the fact that they are null-terminated, and thus they can be [coerced](https://ziglang.org/documentation/0.9.1/#Type-Coercion) to both [Slices](https://ziglang.org/documentation/0.9.1/#Slices) and [Null-Terminated Pointers](https://ziglang.org/documentation/0.9.1/#Sentinel-Terminated-Pointers). Dereferencing string literals converts them to [Arrays](https://ziglang.org/documentation/0.9.1/#Arrays).

Let us break this sentence down into the dialectic style of the Upanishads

> Q: What is a string literal ?  
> A: It is a constant pointer  
> Q: What does it point to ?  
> A: It points to a null-terminated byte array  
> Q: What is a null-terminated byte array ?  
> A: It is an array with a null value at the end. The type info contains the size of the array and the type of the element

The type of "Hello Zig" is therefore `*const [9:0]u8`

Like any pointer, you can also dereference (`*`) a string literal (Crazy, I know!), as string-literals are also pointers according to the documentation. Let us see what we get when we dereference our string-literal.  

```
var input = "Hello Zig".*`;
```

Enter fullscreen mode Exit fullscreen mode

```
./src/main5.zig:12:17: error: expected type '[]u8', found '[9:0]u8'
    alternate_a(input);
```

Enter fullscreen mode Exit fullscreen mode

Close. The `type` of an array encodes its length also.  
When we pass input (an array) as argument, the compiler complains that is expecting a slice, but is getting an `array` instead.

##### [](https://zig.news/gowind/but-will-this-blowup--2j5m#how-do-we-coerce-an-array-into-a-slice-)How do we coerce an array into a slice ?

The zig documentation has a [section](https://ziglang.org/documentation/0.9.1/#Type-Coercion-Slices-Arrays-and-Pointers) on Type coercion between arrays and slice, but _doesn't have a good, illustrative example for coercing \[N:0\]u8 to \[\]u8._

A little bit of experimentation and I figured out that you can turn an array into a slice, by referencing (&) it.  

```
    var input = "Hello Zig".*;
    alternate_a(&input);
```

Enter fullscreen mode Exit fullscreen mode

In this case, the program prints nicely the expected output  

```
Updated string is aeala aia
```

Enter fullscreen mode Exit fullscreen mode

What is my frustration with Zig ? Hard to grok documentation aside, here is something that seems paradoxical to me:  

```
const g = 44;
var gp = &g;
```

Enter fullscreen mode Exit fullscreen mode

This fails with the following error:  

```
./src/main5.zig:16:5: error: variable of type '*const comptime_int' must be const or comptime
    var gp = &g;
```

Enter fullscreen mode Exit fullscreen mode

But this compiles  

```
var input = "Hello Zig";
```

Enter fullscreen mode Exit fullscreen mode

Why is 1) an error , but 2) isn't ?  
  
In both cases, I am trying to make a `var` point to `*const X` , where X is `comptime_int` in 1) and `[9:0]u8` in 2).

Maybe the `comptime_int` is compiled into an `immediate` value in assembly, in which case it doesn't make sense to be able to create an address for it, but what is the case with string-literals then ? Is it stored in the `.bss` section ? or in the `.rodata` section of an ELF ? And what is meant by `*const` ? My understanding from a rudimentary C background is that a `const pointer` cannot be made to point to other things once it is initialized to point to something. If so, `var input = "Hello zig"` should be illegal like case 1). But that is clearly not the case, as I can do something like `input = "Yolo swag";` in the next line.  
Or does it have to do with the fact that string literals are immutable ?  
`input[0] = 'x'` fails, but shouldn't the type be then `*[N:0]const u8` indicating that it is the data that is const and not the pointer itself ?

This behaviour feels very inconsistent and hard for beginners to grasp the language's basics very well. One of the core ethos of Zig is `Communicate intent precisely` and `Reduce the amount one must remember`, aka, be explainable, but the fact that I need to write such a big blog post to understand something as basic as string-literals, to me, implies that these ethos are being violated.

As a long-time Zig follower, I understand that most of Zig is free labour from volunteers and I cannot thank them enough for contributing to this language. That said, jumping into Discord at 3 AM in the morning, everytime i need something rudimentary understood is not the kind of ergonomics that I was looking for, for it is no better than the anything can happen world of `C` or so complicated that a mere mortal cannot understanding in a lifetime complication of `Rust`.

For Zig to be more widely used, a more concerted effort must be make the mechanics of the language understood more easily.

## Discussion (6)

Subscribe

   ![pic](https://zig.news/images/AFnuzE8SEpsvbsWNxqdbyDBQIoo2oKemtXNMk0fGdR4/rs:fill:90:90/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS82MTEv/MjdlMzMxNjQtODJi/Ni00ZTVlLThhZTYt/MmMyNzUyNmNlMTM1/LnBuZw)

 Upload image  

Templates [Editor guide](https://zig.news/p/editor_guide "Markdown Guide")

Personal Moderator

![loading](https://zig.news/assets/loading-ellipsis-b714cf681fd66c853ff6f03dd161b77aa3c80e03cdc06f478b695f42770421e9.svg)

[Create template](https://zig.news/settings/response-templates)

Templates let you quickly answer FAQs or store snippets for re-use.

Submit Preview [Dismiss](https://zig.news/404.html)

Collapse Expand

[![kristoff profile image](https://zig.news/images/oW5lFa8Gfr6lm5npahBtWINgUQxK8Yyu74tjJP9B4gI/rs:fill:50:50/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS8xLzFi/MTE5ZGQwLTYxOTUt/NGMyOC04YzQzLWU1/ZWQ4ZjYzZGQ1Ni5w/bmc)](https://zig.news/kristoff)

[Loris Cro](https://zig.news/kristoff)

Loris Cro

 [![](https://zig.news/images/7VOPwRLqA6tLajN969226Y3-ddOwrLYlJFj9ElIB3SU/rs:fill:90:90/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS8xLzFi/MTE5ZGQwLTYxOTUt/NGMyOC04YzQzLWU1/ZWQ4ZjYzZGQ1Ni5w/bmc)Loris Cro](https://zig.news/kristoff)

Following

I swear I didn't put that bug there

-   Joined
    
    25 Jul 2021
    

• [Jun 25](https://zig.news/kristoff/comment/a8)

Dropdown menu

-   [Copy link](https://zig.news/kristoff/comment/a8)

-   Hide

-   [Report abuse](https://zig.news/report-abuse?url=https://zig.news/kristoff/comment/a8)

The reason why strings behave like this is because of [interning](https://en.wikipedia.org/wiki/String_interning). The variable is allowed to be mutable because it contains a pointer, so, in theory, you could make it point to another string (but not modify the string itself, since multiple vars might refer to the same bytes).

In this case Zig is mainly giving you insight into a process that is present in pretty much all languages.  

```
const g = 44;
var gp = &g;
```

Enter fullscreen mode Exit fullscreen mode

This one is Zig-specific, I believe. Since you're not specifying the type of `g`, you get `comptime_int`, which pulls you into the semantics of comptime evaluation. I believe that in stage2 you will be able to take a pointer from a `comptime_int`, but I'm actually not sure. In other words, this second case is the result of admittedly not-well-defined semantics in the language, but also you most probably want to specify a runtime type for any value that you want the pointer of. Note that during compilation `comptime_int`s are BigInts internally, meaning that taking their pointer is not a basic operation and the compiler must come up with its own design to avoid leaking that implementation detail.

Like comment: Like comment: 3 likes [Comment button Reply](https://zig.news/gowind/but-will-this-blowup--2j5m#/gowind/when-a-var-really-isnt-a-var-ft-string-literals-1hn7/comments/new/a8)

Collapse Expand

[![gowind profile image](https://zig.news/images/3dgm2ia6t7-n61xejLJxkpGaaTZ1kngXuyjqX_MmsjM/rs:fill:50:50/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS8xODYv/N2FlNjY5OGUtZWQ2/OC00YmY5LWE4MDAt/ZTNlNzE1MzhiYmY3/LmpwZWc)](https://zig.news/gowind)

[Govind Author](https://zig.news/gowind)

Govind

 [![](https://zig.news/images/qsLCBnzer13wa3qju94JsorzAXlT8TUjFHJoHeUQD5A/rs:fill:90:90/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS8xODYv/N2FlNjY5OGUtZWQ2/OC00YmY5LWE4MDAt/ZTNlNzE1MzhiYmY3/LmpwZWc)Govind](https://zig.news/gowind)

Following

Ever curious about the machine

-   Joined
    
    18 Aug 2021
    

Author

• [Jun 26 • Edited on Jun 26](https://zig.news/gowind/comment/a9)

Dropdown menu

-   [Copy link](https://zig.news/gowind/comment/a9)

-   Hide

-   [Report abuse](https://zig.news/report-abuse?url=https://zig.news/gowind/comment/a9)

Thanks for the reply !  
The Zig specific behaviour of `comptime_int` makes more sense , but for strings I can still do `var input = "Hello Zig".*` and then modify it to something like `input[0] = 'a'` and input actually changes to `aello Zig`. What happens in this case?  
Does Zig create a copy of `Hello Zig` on the stack, or does it create a completely new String and then modified that ?

Like comment: Like comment: 1 like [Comment button Reply](https://zig.news/gowind/but-will-this-blowup--2j5m#/gowind/when-a-var-really-isnt-a-var-ft-string-literals-1hn7/comments/new/a9)

Collapse Expand

[![kristoff profile image](https://zig.news/images/oW5lFa8Gfr6lm5npahBtWINgUQxK8Yyu74tjJP9B4gI/rs:fill:50:50/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS8xLzFi/MTE5ZGQwLTYxOTUt/NGMyOC04YzQzLWU1/ZWQ4ZjYzZGQ1Ni5w/bmc)](https://zig.news/kristoff)

[Loris Cro](https://zig.news/kristoff)

Loris Cro

 [![](https://zig.news/images/7VOPwRLqA6tLajN969226Y3-ddOwrLYlJFj9ElIB3SU/rs:fill:90:90/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS8xLzFi/MTE5ZGQwLTYxOTUt/NGMyOC04YzQzLWU1/ZWQ4ZjYzZGQ1Ni5w/bmc)Loris Cro](https://zig.news/kristoff)

Following

I swear I didn't put that bug there

-   Joined
    
    25 Jul 2021
    

• [Jun 26 • Edited on Jun 26](https://zig.news/kristoff/comment/aa)

Dropdown menu

-   [Copy link](https://zig.news/kristoff/comment/aa)

-   Hide

-   [Report abuse](https://zig.news/report-abuse?url=https://zig.news/kristoff/comment/aa)

`"Hello Zig"` is a chunk of memory inside the `.rodata` of your executable (or something of that sort, I believe different architecture-specific backends can decide where this stuff goes). So when you assing it to a variable, you get a pointer to those bytes.

When you dereference the pointer you get the full array contents which, yes, get copied to stack memory (assuming we're inside a function) and that then you can modify, since that memory is yours. If you look at the types it's very clear and consistent (if you know about string interning).  

```
var str_ptr = "hi"; // type: *const [2:0]u8
var a = str_ptr.*; // type: [2:0]u8 
var b = [2:0]u8 {'y', 'o'}; // type: same as `a`
a = &b; // allowed since `b`'s type matches and `a` is var
```

Enter fullscreen mode Exit fullscreen mode

Like comment: Like comment: 2 likes Thread Thread

[![gowind profile image](https://zig.news/images/3dgm2ia6t7-n61xejLJxkpGaaTZ1kngXuyjqX_MmsjM/rs:fill:50:50/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS8xODYv/N2FlNjY5OGUtZWQ2/OC00YmY5LWE4MDAt/ZTNlNzE1MzhiYmY3/LmpwZWc)](https://zig.news/gowind)

[Govind Author](https://zig.news/gowind)

Govind

 [![](https://zig.news/images/qsLCBnzer13wa3qju94JsorzAXlT8TUjFHJoHeUQD5A/rs:fill:90:90/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS8xODYv/N2FlNjY5OGUtZWQ2/OC00YmY5LWE4MDAt/ZTNlNzE1MzhiYmY3/LmpwZWc)Govind](https://zig.news/gowind)

Following

Ever curious about the machine

-   Joined
    
    18 Aug 2021
    

Author

• [Jun 27](https://zig.news/gowind/comment/ab)

Dropdown menu

-   [Copy link](https://zig.news/gowind/comment/ab)

-   Hide

-   [Report abuse](https://zig.news/report-abuse?url=https://zig.news/gowind/comment/ab)

> When you dereference the pointer you get the full array contents which, yes, get copied to stack memory (assuming we're inside a function) and that then you can modify, since that memory is yours

Ok, this is the context I was missing (basically dereferring "x".\*) creates a copy on the Stack that I can then modify. Thanks !

Like comment: Like comment: 3 likes [Comment button Reply](https://zig.news/gowind/but-will-this-blowup--2j5m#/gowind/when-a-var-really-isnt-a-var-ft-string-literals-1hn7/comments/new/ab)

Collapse Expand

[![yanwenjiepy profile image](https://zig.news/images/HRLXfhTSstgwWE4o3UjOKWDoU-JceWX9kxCYuuceNyE/rs:fill:50:50/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS80MzYv/NzBjZDNjZGQtYTVl/MC00NWY5LWIxYTct/NDZjODdiZTYxYmY1/LmpwZWc)](https://zig.news/yanwenjiepy)

[花大喵](https://zig.news/yanwenjiepy)

花大喵

 [![](https://zig.news/images/MoyvjyAI0_qNFioU1-WwtvMMzZDDtSAnzPW7XdD1Izk/rs:fill:90:90/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS80MzYv/NzBjZDNjZGQtYTVl/MC00NWY5LWIxYTct/NDZjODdiZTYxYmY1/LmpwZWc)花大喵](https://zig.news/yanwenjiepy)

Follow

-   Joined
    
    7 Feb 2022
    

• [Jun 24](https://zig.news/yanwenjiepy/comment/a7)

Dropdown menu

-   [Copy link](https://zig.news/yanwenjiepy/comment/a7)

-   Hide

-   [Report abuse](https://zig.news/report-abuse?url=https://zig.news/yanwenjiepy/comment/a7)

You have done a good job. For ordinary programmers, even if there are complete and clear documents in many programming languages, there will still be a lot of confusion. Zig is even more lacking in documentation. Learning resources about zig need everyone to work together. Make an effort to enrich it and make it easier to understand and learn. I have to say, zig still has a long way to go.

Like comment: Like comment: 2 likes [Comment button Reply](https://zig.news/gowind/but-will-this-blowup--2j5m#/gowind/when-a-var-really-isnt-a-var-ft-string-literals-1hn7/comments/new/a7)

Collapse Expand

[![gowind profile image](https://zig.news/images/3dgm2ia6t7-n61xejLJxkpGaaTZ1kngXuyjqX_MmsjM/rs:fill:50:50/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS8xODYv/N2FlNjY5OGUtZWQ2/OC00YmY5LWE4MDAt/ZTNlNzE1MzhiYmY3/LmpwZWc)](https://zig.news/gowind)

[Govind Author](https://zig.news/gowind)

Govind

 [![](https://zig.news/images/qsLCBnzer13wa3qju94JsorzAXlT8TUjFHJoHeUQD5A/rs:fill:90:90/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS8xODYv/N2FlNjY5OGUtZWQ2/OC00YmY5LWE4MDAt/ZTNlNzE1MzhiYmY3/LmpwZWc)Govind](https://zig.news/gowind)

Following

Ever curious about the machine

-   Joined
    
    18 Aug 2021
    

Author

• [Jun 27](https://zig.news/gowind/comment/ac)

Dropdown menu

-   [Copy link](https://zig.news/gowind/comment/ac)

-   Hide

-   [Report abuse](https://zig.news/report-abuse?url=https://zig.news/gowind/comment/ac)

Thanks. I will be trying to writing more such content about the internals of PLs and Zig to get people to jump from the beginner -> learned person level.

Like comment: Like comment: 2 likes [Comment button Reply](https://zig.news/gowind/but-will-this-blowup--2j5m#/gowind/when-a-var-really-isnt-a-var-ft-string-literals-1hn7/comments/new/ac)

[Code of Conduct](https://zig.news/code-of-conduct) • [Report abuse](https://zig.news/report-abuse)

Are you sure you want to hide this comment? It will become hidden in your post, but will still be visible via the comment's [permalink](https://zig.news/gowind/but-will-this-blowup--2j5m#).

Hide child comments as well

Confirm

For further actions, you may consider blocking this person and/or [reporting abuse](https://zig.news/report-abuse)

## Read next

[

![kprotty profile image](https://zig.news/images/NuK7FKfHmVA6Qv2x6pSO-nVDVqtWwFm7FuiS-Q2277Q/s:100:100/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS8xMC85/N2ViOThlNi0yMjky/LTRhZjYtYjQ5Ni1k/ZjM0ZjYzYzIxYmIu/anBn)

### Resource efficient Thread Pools with Zig

Protty - Sep 12 '21





](https://zig.news/kprotty/resource-efficient-thread-pools-with-zig-3291)[

![sobeston profile image](https://zig.news/images/SYgg7xNvWKW9MEN3HYe02qUuu1vEX7yzH7-3LGHq-FY/s:100:100/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS83Ny80/NTJmYmMyOC1kY2Zl/LTQ2ZjAtODYzYi1k/NjgwZjk0NGEyNWEu/cG5n)

### Fizz Buzz

Sobeston - Sep 13 '21





](https://zig.news/sobeston/fizz-buzz-3fao)[

![sobeston profile image](https://zig.news/images/SYgg7xNvWKW9MEN3HYe02qUuu1vEX7yzH7-3LGHq-FY/s:100:100/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS83Ny80/NTJmYmMyOC1kY2Zl/LTQ2ZjAtODYzYi1k/NjgwZjk0NGEyNWEu/cG5n)

### A Guessing Game

Sobeston - Sep 13 '21





](https://zig.news/sobeston/a-guessing-game-5fb1)[

![sobeston profile image](https://zig.news/images/SYgg7xNvWKW9MEN3HYe02qUuu1vEX7yzH7-3LGHq-FY/s:100:100/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS83Ny80/NTJmYmMyOC1kY2Zl/LTQ2ZjAtODYzYi1k/NjgwZjk0NGEyNWEu/cG5n)

### Fahrenheit To Celsius

Sobeston - Sep 13 '21





](https://zig.news/sobeston/fahrenheit-to-celsius-akf)
