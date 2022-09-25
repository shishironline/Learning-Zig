---
id: 0y5oeergq341yoh7w5cwh6p
title: Zig files are structs
desc: ''
updated: 1664097329565
created: 1664097270844
---
[Zig files are structs](https://zig.news/gowind/zig-files-are-structs-288j)

---
created: 2022-09-25T14:45:08 (UTC +05:30)
tags: [ziglang,zig,howto,tutorial,learn]
source: https://zig.news/gowind/but-will-this-blowup--2j5m
author: 
created with: MarkDownload - Markdown Web Clipper
---

# Zig files are structs - Zig NEWS ⚡

> ## Excerpt
> Read the latest happenings in the global Zig community.

---
[![Govind](https://zig.news/images/3dgm2ia6t7-n61xejLJxkpGaaTZ1kngXuyjqX_MmsjM/rs:fill:50:50/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS8xODYv/N2FlNjY5OGUtZWQ2/OC00YmY5LWE4MDAt/ZTNlNzE1MzhiYmY3/LmpwZWc)](https://zig.news/gowind)

[Govind](https://zig.news/gowind)

Posted on 13 Jul

# Zig files are structs

[#learn](https://zig.news/t/learn)

While exploring the [Allocator](https://github.com/ziglang/zig/blob/master/lib/std/mem/Allocator.zig) interface, I came the lines  

```
// The type erased pointer to the allocator implementation
ptr: *anyopaque,
vtable: *const VTable,
```

Enter fullscreen mode Exit fullscreen mode

in the file that felt out of place. The seemed like file level globals, but without a `var` or a `const` declaration.  
Turns out, files are compiled into structs.

As an example, this is how we can verify this.  

```
cat module1.zig
a: u32,
b: u32,
```

Enter fullscreen mode Exit fullscreen mode

```
cat module2.zig
const m1 = @import("module1.zig");
const std = @import("std");

pub fn main() !void {
    var s = m1{ .a = 43, .b = 46 };
    std.debug.print("{}\n", .{s.a});
}
```

Enter fullscreen mode Exit fullscreen mode

Running module2.zig using `zig run module2.zig`, I get :  
`43`

## Discussion (2)

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

[![webermartin profile image](https://zig.news/images/5IjWS3j0ZBa_r6cnP5IsjQEq55HcID_f51M9v_fzL7g/rs:fill:50:50/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS81MDAv/MTk3ZWY5Y2ItMWZi/OC00ZTYzLThiOTkt/OWEwNjA5OGVlYTk5/LnBuZw)](https://zig.news/webermartin)

[weber-martin](https://zig.news/webermartin)

weber-martin

 [![](https://zig.news/images/tlJfEity6fh7iDWmEVY2A_u4dl5-9trYopeeLrgtb-Q/rs:fill:90:90/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS81MDAv/MTk3ZWY5Y2ItMWZi/OC00ZTYzLThiOTkt/OWEwNjA5OGVlYTk5/LnBuZw)weber-martin](https://zig.news/webermartin)

Follow

-   Joined
    
    17 May 2022
    

• [Jul 14](https://zig.news/webermartin/comment/al)

Dropdown menu

-   [Copy link](https://zig.news/webermartin/comment/al)

-   Hide

-   [Report abuse](https://zig.news/report-abuse?url=https://zig.news/webermartin/comment/al)

This is also documented here: [ziglang.org/documentation/0.9.1/#i...](https://ziglang.org/documentation/0.9.1/#import)

> Zig source files are implicitly structs, with a name equal to the file's basename with the extension truncated. @import returns the struct type corresponding to the file.

Like comment: Like comment: 2 likes [Comment button Reply](https://zig.news/gowind/but-will-this-blowup--2j5m#/gowind/zig-files-are-structs-288j/comments/new/al)

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

• [Jul 15](https://zig.news/gowind/comment/an)

Dropdown menu

-   [Copy link](https://zig.news/gowind/comment/an)

-   Hide

-   [Report abuse](https://zig.news/report-abuse?url=https://zig.news/gowind/comment/an)

Thanks, I did not notice this in the std. documentation ! Leaving this here anyway for someone if they are interested.

Like comment: Like comment: 2 likes [Comment button Reply](https://zig.news/gowind/but-will-this-blowup--2j5m#/gowind/zig-files-are-structs-288j/comments/new/an)

[Code of Conduct](https://zig.news/code-of-conduct) • [Report abuse](https://zig.news/report-abuse)

Are you sure you want to hide this comment? It will become hidden in your post, but will still be visible via the comment's [permalink](https://zig.news/gowind/but-will-this-blowup--2j5m#).

Hide child comments as well

Confirm

For further actions, you may consider blocking this person and/or [reporting abuse](https://zig.news/report-abuse)

## Read next

[

![r4gus profile image](https://zig.news/images/DyhQRKmY9XKs2mp8jB79jPEH_7_Pfd3EXjZGB4h-f7A/s:100:100/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS81NTIv/NDhiYWVkNDMtMTk4/Yy00OGQ1LWI0NjAt/MzkyMDdjZGYxYTdm/LmpwZWc)

### Programming SAM E51 Curiosity Nano with Zig

David Sugar - Aug 7





](https://zig.news/r4gus/programming-sam-e51-curiosity-nano-with-zig-3hgd)[

![lupyuen profile image](https://zig.news/images/HeerEdpjz8TadZYHofEkwNFyfQRZgUNX6WPRQJeOTo8/s:100:100/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS81MTMv/YTAxY2JiNDAtNTMz/My00ZDk3LTkxMWIt/YTUzMWFhZWYzMTZm/LmpwZWc)

### Read NuttX Sensor Data with Zig

Lup Yuen Lee - Jul 30





](https://zig.news/lupyuen/read-nuttx-sensor-data-with-zig-12ki)[

![xq profile image](https://zig.news/images/bJRy3qkj5ZVNjuQo_Dfo5FEEkEoeQ7XPo2Pj5VxPops/s:100:100/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS8xMi9m/Mzg3NmViMS0wMWRk/LTRhMTItYjgwMC1j/YmM5N2FkYjZjZTcu/anBn)

### Re: Makin' wavs with Zig

Felix "xq" Queißner - Jul 22





](https://zig.news/xq/re-makin-wavs-with-zig-1jjd)[

![lupyuen profile image](https://zig.news/images/HeerEdpjz8TadZYHofEkwNFyfQRZgUNX6WPRQJeOTo8/s:100:100/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS81MTMv/YTAxY2JiNDAtNTMz/My00ZDk3LTkxMWIt/YTUzMWFhZWYzMTZm/LmpwZWc)

### Build an LVGL Touchscreen App with Zig

Lup Yuen Lee - Jul 12





](https://zig.news/lupyuen/build-an-lvgl-touchscreen-app-with-zig-38lm)
