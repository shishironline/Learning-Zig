---
id: z3au108topcid447h80v59h
title: Where is print function in Zig
desc: ''
updated: 1664094726803
created: 1664094622195
---
[Where is print() in Zig?]()

---
created: 2022-09-25T14:01:47 (UTC +05:30)
tags: [beginners,learn,ziglang,zig]
source: https://zig.news/kristoff/where-is-print-in-zig-57e9
author: Loris Cro
---

# Where is print() in Zig? - Zig NEWS

> ## Excerpt
> Zig has no built-in print function or statement. If you want to print something quickly, you can use...

---
[Loris Cro](https://zig.news/kristoff)

Posted on 5 Aug 2021 • Updated on 8 Aug 2021

# Where is print() in Zig?

[#beginners](https://zig.news/t/beginners) [#learn](https://zig.news/t/learn)

Zig has no built-in print function or statement.  
If you want to print something quickly, you can use `std.debug.print`:  

```
const std = @import("std");

pub fn main() void {
   std.debug.print("Hello World!", .{});
}
```

Enter fullscreen mode Exit fullscreen mode

# [](https://zig.news/kristoff/where-is-print-in-zig-57e9#why-is-there-no-builtin-function-like-cs-raw-printf-endraw-)Why is there no built-in function like C's `printf`?

One answer is that, unlike C, Zig doesn't need to special-case the printing function. In C, `printf` could not be implemented as a normal function without losing its special compile-time checks (i.e., the compiler can check that the number of arguments passed to `printf` matches the number of `%` placeholders in the format string).

In Zig all of that can be implemented in userland using comptime checks.

Another reason why Zig has no built-in print function is that printing is less obvious than what some other languages would lead you to believe.

# [](https://zig.news/kristoff/where-is-print-in-zig-57e9#when-printing-becomes-actually-important)When printing becomes actually important

When you are just printing a debug line to the console, you don't care about handling error conditions, but **sometimes printing to the terminal is the core functionality of your application** and at that point, to write a robust tool, you will need to design for failure.

On top of that there might be performance implications related to buffering, or you might be sharing the output stream with other threads, at which point a lock might (or might not) be necessary to ensure that the printed information keeps making sense.

Earlier we saw `std.debug.print` and that function made some choices for us:

-   it prints to stderr
-   it has a lock in case you have multiple threads
-   it does not buffer
-   errors get discarded

This is its implementation ([from the stdlib](https://github.com/ziglang/zig/blob/master/lib/std/debug.zig#L69-L74)):  

```
pub fn print(comptime fmt: []const u8, args: anytype) void {
    const held = stderr_mutex.acquire();
    defer held.release();
    const stderr = io.getStdErr().writer();
    nosuspend stderr.print(fmt, args) catch return;
}
```

Enter fullscreen mode Exit fullscreen mode

# [](https://zig.news/kristoff/where-is-print-in-zig-57e9#printing-more-reliably)Printing more reliably

To print in a more reliable way, you can use `std.log`, which also works as a more complete logging system with support for different scopes and levels. You can read more about it [in the stdlib](https://github.com/ziglang/zig/blob/master/lib/std/log.zig#L7).

## [](https://zig.news/kristoff/where-is-print-in-zig-57e9#printing-to-stdout)Printing to stdout

If you want to have direct access to stdout, you can use `std.io.getStdOut()` and from there use the `writer` interface to print, just like the code above does with stderr. At that point it will be up to you if you want to have buffering (using a `std.io.BufferedWriter`) or a lock, and you will also have to decide what to do with errors.

# [](https://zig.news/kristoff/where-is-print-in-zig-57e9#watch-the-talk)Watch the talk

If you want to listen to me give a full talk just on this topic, here you go :^)

<iframe width="710" height="399" src="https://www.youtube.com/embed/iZFXAN8kpPo" allowfullscreen="" loading="lazy" class=" fluidvids-elem"></iframe>

## Discussion (0)

Subscribe

   ![pic](https://zig.news/images/8DahqU2dnVVAwwhWndAuOZD4fxO-MYJObmxV1mWxMF8/w:256/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L2FydGljbGVzL3pr/YWVtbzNuMDJjYW13/bWwzYXJjLnBuZw)

 Upload image  

Templates [Editor guide](https://zig.news/p/editor_guide "Markdown Guide")

Personal Moderator

![loading](https://zig.news/assets/loading-ellipsis-b714cf681fd66c853ff6f03dd161b77aa3c80e03cdc06f478b695f42770421e9.svg)

[Create template](https://zig.news/settings/response-templates)

Templates let you quickly answer FAQs or store snippets for re-use.

Submit Preview [Dismiss](https://zig.news/404.html)

[Code of Conduct](https://zig.news/code-of-conduct) • [Report abuse](https://zig.news/report-abuse)

Are you sure you want to hide this comment? It will become hidden in your post, but will still be visible via the comment's [permalink](https://zig.news/kristoff/where-is-print-in-zig-57e9#).

Hide child comments as well

Confirm

For further actions, you may consider blocking this person and/or [reporting abuse](https://zig.news/report-abuse)

## Read next

[

![gowind profile image](https://zig.news/images/ouhB9qD3K1oz-Sis9JzfC5c7Adv2v2Fw9Jpv_n5xd0M/s:100:100/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS8xODYv/N2FlNjY5OGUtZWQ2/OC00YmY5LWE4MDAt/ZTNlNzE1MzhiYmY3/LmpwZWc)

### When a var really isn't a var (ft. String Literals)

Govind - Jun 24





](https://zig.news/gowind/when-a-var-really-isnt-a-var-ft-string-literals-1hn7)[

![noodlez profile image](https://zig.news/images/hCOGBeSGyhs21M1DCANsKF0SSotJytRC4q82A4cfEJI/s:100:100/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS81MTgv/NzQzYzQyNWUtYTkw/ZS00YjA5LTkyYmEt/YzdiZjU2MGZhZTgz/LnBuZw)

### Why isn't my file being compiled

Nathaniel Barragan - Jun 19





](https://zig.news/noodlez/why-isnt-my-file-being-compiled-4jhj)[

![lupyuen profile image](https://zig.news/images/HeerEdpjz8TadZYHofEkwNFyfQRZgUNX6WPRQJeOTo8/s:100:100/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS81MTMv/YTAxY2JiNDAtNTMz/My00ZDk3LTkxMWIt/YTUzMWFhZWYzMTZm/LmpwZWc)

### Build an IoT App with Zig and LoRaWAN

Lup Yuen Lee - Jun 15





](https://zig.news/lupyuen/build-an-iot-app-with-zig-and-lorawan-5c3m)[

![lupyuen profile image](https://zig.news/images/HeerEdpjz8TadZYHofEkwNFyfQRZgUNX6WPRQJeOTo8/s:100:100/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS81MTMv/YTAxY2JiNDAtNTMz/My00ZDk3LTkxMWIt/YTUzMWFhZWYzMTZm/LmpwZWc)

### Zig on RISC-V BL602: Quick Peek with Apache NuttX RTOS

Lup Yuen Lee - Jun 3





](https://zig.news/lupyuen/zig-on-risc-v-bl602-quick-peek-with-apache-nuttx-rtos-3apd)

 [![](https://zig.news/images/7VOPwRLqA6tLajN969226Y3-ddOwrLYlJFj9ElIB3SU/rs:fill:90:90/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS8xLzFi/MTE5ZGQwLTYxOTUt/NGMyOC04YzQzLWU1/ZWQ4ZjYzZGQ1Ni5w/bmc)Loris Cro](https://zig.news/kristoff)

Follow

I swear I didn't put that bug there

-   Joined
    
    25 Jul 2021
    

### More from [Loris Cro](https://zig.news/kristoff)

[Compile a C/C++ Project with Zig

#zigcc #c #cpp #beginners

](https://zig.news/kristoff/compile-a-c-c-project-with-zig-368j)[Struct of Arrays (SoA) in Zig? Easy & in Userland!

#learn #datastructure #gamedev

](https://zig.news/kristoff/struct-of-arrays-soa-in-zig-easy-in-userland-40m0)[What's undefined in Zig?

#beginners #learn

](https://zig.news/kristoff/what-s-undefined-in-zig-9h)
