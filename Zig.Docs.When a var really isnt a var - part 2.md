---
id: 2n0c5c6i9bjeui23glsa5w9
title: When a var really isnt a var - part 2
desc: ''
updated: 1664098205023
created: 1664098148574
---
[When a var really isn't a var - part 2](https://zig.news/gowind/when-a-var-really-isnt-a-var-part-2-4l7k)

---
created: 2022-09-25T14:59:54 (UTC +05:30)
tags: [ziglang,zig,howto,tutorial,learn]
source: https://zig.news/gowind/but-will-this-blowup--2j5m
author: 
created with: MarkDownload - Markdown Web Clipper
---

# When a var really isn't a var - part 2 - Zig NEWS ⚡

> ## Excerpt
> Read the latest happenings in the global Zig community.

---
[Govind](https://zig.news/gowind)

Posted on 13 Jul

# When a var really isn't a var - part 2

[#learn](https://zig.news/t/learn)

This is a small follow up to my [previous](https://zig.news/gowind/when-a-var-really-isnt-a-var-ft-string-literals-1hn7) post about vars and consts.

In my post I was wonder why `var input = "Hello Zig".*` would let me edit it `input[0] = 'a'`, for example, when string literals are constants.  
As pointed out by [@kristoff](https://zig.news/kristoff) , turns out `"Literal".*` creates a copy on the stack.

This can be verified by looking at the generated assembly (x86\_64 atleast)  

```
0000000000225aa0 <main>:
  225aa0:   55                      push   rbp
  225aa1:   48 89 e5                mov    rbp,rsp
  225aa4:   48 83 ec 20             sub    rsp,0x20
  225aa8:   48 8b 04 25 e2 38 20    mov    rax,QWORD PTR ds:0x2038e2
  225aaf:   00
  225ab0:   48 89 45 f6             mov    QWORD PTR [rbp-0xa],rax
  225ab4:   66 8b 04 25 ea 38 20    mov    ax,WORD PTR ds:0x2038ea
  225abb:   00
  225abc:   66 89 45 fe             mov    WORD PTR [rbp-0x2],ax
  225ac0:   48 8b 45 f6             mov    rax,QWORD PTR [rbp-0xa]
  225ac4:   48 89 45 e8             mov    QWORD PTR [rbp-0x18],rax
  225ac8:   66 8b 45 fe             mov    ax,WORD PTR [rbp-0x2]
  225acc:   66 89 45 f0             mov    WORD PTR [rbp-0x10],ax
  225ad0:   48 8d 7d e8             lea    rdi,[rbp-0x18]
  225ad4:   e8 e7 5c 00 00          call   22b7c0 <std.debug.print.103>
  225ad9:   48 83 c4 20             add    rsp,0x20
  225add:   5d                      pop    rbp
  225ade:   c3                      ret
  225adf:   90                      nop
```

Enter fullscreen mode Exit fullscreen mode

`0x2038ea` points to the address where our string is stored in the ELF  

```
2038e0 29004861 69207468 65726500 64776172  ).Hai there.dwar
2038f0 663a2075 6e68616e 646c6564 20666f72  f: unhandled for
```

Enter fullscreen mode Exit fullscreen mode

We first make 32 bytes of space on the stack (`sub rsp 0x20`) and then copy the string literal starting at address 0xa to 0x2 using 2 instructions ("Hai There" is 9 bytes, so we copy 8 bytes using the first instruction and then the last byte using another)  
We then copy the string into the stack from rbp-0x18 to rbp-0x10 and call `debug.print` with the base address to our copy (rbp-0x18)

## Discussion (0)

Subscribe

   ![pic](https://zig.news/images/AFnuzE8SEpsvbsWNxqdbyDBQIoo2oKemtXNMk0fGdR4/rs:fill:90:90/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS82MTEv/MjdlMzMxNjQtODJi/Ni00ZTVlLThhZTYt/MmMyNzUyNmNlMTM1/LnBuZw)

 Upload image  

Templates [Editor guide](https://zig.news/p/editor_guide "Markdown Guide")

Personal Moderator

![loading](https://zig.news/assets/loading-ellipsis-b714cf681fd66c853ff6f03dd161b77aa3c80e03cdc06f478b695f42770421e9.svg)

[Create template](https://zig.news/settings/response-templates)

Templates let you quickly answer FAQs or store snippets for re-use.

Submit Preview [Dismiss](https://zig.news/404.html)

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
