---
id: i6jp9bij16u9p5wpanxkmkq
title: But will this blow up
desc: ''
updated: 1664097126884
created: 1664097062482
---
[But, will this blow up](https://zig.news/gowind/but-will-this-blowup--2j5m)

---
created: 2022-09-25T14:41:27 (UTC +05:30)
tags: [ziglang,zig,howto,tutorial,learn]
source: https://zig.news/gowind/but-will-this-blowup--2j5m
author: 
created with: MarkDownload - Markdown Web Clipper
---

# But, will this blow up ? - Zig NEWS ⚡

> ## Excerpt
> Read the latest happenings in the global Zig community.

---
# But, will this blow up ?

[#learn](https://zig.news/t/learn)

The source for this post can be found [here](https://github.com/GoWind/algorithms/blob/master/vtables/calculator_interface.zig)  
Say you see something like this:  

```
pub fn initStack(ptr: *anyopaque, comptime addI: addProto, comptime subI: subProto, comptime mulI: mulProto, comptime divI: divProto) Calculator {
const vtable = VTable{
        .add = addI,
        .sub = subI,
        .mul = mulI,
        .div = divI,
    };

    return .{ .ptr = ptr, .vtable = &vtable };
```

Enter fullscreen mode Exit fullscreen mode

Anyone with C/C++ experience will immediately panic on seeing something like this, as you are returning a pointer (`&vtable`) to something that is on the stack and just praying for a `SegmentationFault` .

But is that true ? What happens when we actually run this ?  

```

pub fn main() void {
    var i = Implementation.init(@as(i32, 45));
    var imi = i.myInterface();
    print("{}\n", .{imi.add(@as(i32, 10), @as(i32, 20))});
    print("{}\n", .{imi.div(@as(f32, 12.0), @as(f32, 2.10))});

    var imiS = i.myInterfaceStack();
    print("{} \n", .{imiS.add(@as(i32, 10), @as(i32, 20))});
    print("{} \n", .{imiS.div(@as(f32, 12.0), @as(f32, 2.10))});
}
```

Enter fullscreen mode Exit fullscreen mode

```
Output:
my add implementation 30
my div implementation 5.71428585e+00
my add implementation 30
my div implementation 5.71428585e+00
```

Enter fullscreen mode Exit fullscreen mode

And it worked without a `SegFault` ! How is that happening ?  
Curious, I tried to disassembly the `.exe` file and look at the assembly code. You can do so simply with  

```
zig build-exe -target x86_64-linux-gnu calculator_implementation.zig

objdump -cpu=intel   --x86-asm-syntax=intel --disassemble-all calculator_implementation > calc_out.txt
```

Enter fullscreen mode Exit fullscreen mode

If you look at the assembly listing for the symbol `calculator_interface.initStack` (notice that `fns` inside structs are nothing but namespaced fns in the assembly), you will find some interesting things:  

```

  239a10: 55                            push    rbp
  239a11: 48 89 e5                      mov rbp, rsp
  239a14: 50                            push    rax
  239a15: 48 89 f8                      mov rax, rdi
  239a18: 48 89 75 f8                   mov qword ptr [rbp - 8], rsi
  239a1c: 48 8b 4d f8                   mov rcx, qword ptr [rbp - 8]
  239a20: 48 89 0f                      mov qword ptr [rdi], rcx
  239a23: 48 b9 20 e9 20 00 00 00 00 00 movabs  rcx, 2156832
  239a2d: 48 89 4f 08                   mov qword ptr [rdi + 8], rcx
  239a31: 48 83 c4 08                   add rsp, 8
  239a35: 5d                            pop rbp
  239a36: c3                            ret
  239a37: 66 0f 1f 84 00 00 00 00 00    nop word ptr [rax + rax]
```

Enter fullscreen mode Exit fullscreen mode

checking against the declaration of `initStack` : `pub fn initStack(ptr: *anyopaque, comptime addI: addProto, ...) Calculator {`  
It looks like `ptr` is copied to address at `rdi` and `rdi + 8` is set to the value `2156832` (decimal)

Where is `2156832` (hex: `20e920`) ?  
This is in the `.rodata` section of the assembly (**Note** that our addresses in `initStack` here have a prefix `23...`)  
Lets look at the data in `20e920`:  

```
  20e920: 00 e2                         add dl, ah
  20e922: 23 00                         and eax, dword ptr [rax]
  20e924: 00 00                         add byte ptr [rax], al
  20e926: 00 00                         add byte ptr [rax], al
  20e928: 00 e3                         add bl, ah
  20e92a: 23 00                         and eax, dword ptr [rax]
  20e92c: 00 00                         add byte ptr [rax], al
  20e92e: 00 00                         add byte ptr [rax], al
  20e930: 00 e4                         add ah, ah
  20e932: 23 00                         and eax, dword ptr [rax]
  20e934: 00 00                         add byte ptr [rax], al
  20e936: 00 00                         add byte ptr [rax], al
  20e938: 00 e5                         add ch, ah
  20e93a: 23 00                         and eax, dword ptr [rax]
```

Enter fullscreen mode Exit fullscreen mode

(Ignore the instructions, for they are false. This is `.rodata` section, so it contains only data)  
Intel assembly is Little Endian, so we read values from higher address -> lower address. Therefore,  
The first 8 byte value is : `00 00 00 00 00 23 e2 00`  
The second 8 byte value is `00 00 00 00 00 23 e3 00`  
3rd: `00 00 00 00 00 23 e4 00`  
4rd: `00 00 00 00 00 23 e4 00`

These `23...` address. seem familiar. Let us look at the instructions at `23 e2 00`  

```
000000000023e200 <Implementation.add>:
  23e200: 55                            push    rbp
  23e201: 48 89 e5                      mov rbp, rsp
  23e204: 48 83 ec 20                   sub rsp, 32
  23e208: 48 89 7d f0                   mov qword ptr [rbp - 16], rdi
  23e20c: 89 75 ec                      mov dword ptr [rbp - 20], esi
  23e20f: 89 55 e8                      mov dword ptr [rbp - 24], edx
  23e212: e8 39 00 00 00                call    0x23e250 <std.debug.print.153>
  23e217: 8b 45 ec                      mov eax, dword ptr [rbp - 20]
  23e21a: 03 45 e8                      add eax, dword ptr [rbp - 24]
  23e21d: 89 45 e4                      mov dword ptr [rbp - 28], eax
  23e220: 0f 90 c0                      seto    al
  23e223: 70 02                         jo  0x23e227 <Implementation.add+0x27>
  23e225: eb 13                         jmp 0x23e23a <Implementation.add+0x3a>
  23e227: 48 bf 60 d5 20 00 00 00 00 00 movabs  rdi, 2151776
  23e231: 31 c0                         xor eax, eax
```

Enter fullscreen mode Exit fullscreen mode

And boom ! These are the addresses of our implementing functions !!

**Here is the strange thing** : We were expecting our `&vtable` to point to addresses in the Stack, but it turned out to be addresses in the actual assembly itself ? How is that ?

The secret lies in the declaration of our fn and the magic of `comptime`  

```
pub fn initStack(ptr: *anyopaque, comptime addI: addProto, comptime subI: subProto, comptime mulI: mulProto, comptime divI: divProto) Calculator {
```

Enter fullscreen mode Exit fullscreen mode

Since our `vtable` is a `const` and its values are `comptime` known, Zig is smart enough to create this `const` as a part of the assembly itself. Therefore, when we return a pointer to `vtable`, it points to an address inside `.rodata` and not into the stack of `initStack`

This pattern is however unusual.  
Most interface implementation (such as `Allocator`) in Zig, create a intermediate struct with namespaced fn's to call the `fns` passed as args  

```
//comptime is the key, as it lets us know
//the signature of the implementing function at compile time

    // A clever trick. addI or subI will have a type-signature of fn(c: *ConcreteType, ..args)
    // our interface has a type-erased `ptr` that we need to send to addI or subI
    // we sort of `wrap` addI or subI to allow passing this type erased pointer without a
    // compile error (of type mismatch)
    const gen = struct {
        pub fn addProtoImpl(ptr: *anyopaque, x: i32, y: i32) i32 {
            return @call(.{}, addI, .{ ptr, x, y });
        }
        pub fn subProtoImpl(ptr: *anyopaque, x: i32, y: i32) i32 {
            return @call(.{}, subI, .{ ptr, x, y });
        }
        pub fn mulProtoImpl(ptr: *anyopaque, x: i32, y: i32) i32 {
            return @call(.{}, mulI, .{ ptr, x, y });
        }
        pub fn divProtoImpl(ptr: *anyopaque, x: f32, y: f32) f32 {
            return @call(.{}, divI, .{ ptr, x, y });
        }
        // All `fns` are part of the `.text` section of the binary
        // so for each implementation , we know where exactly to `jmp`
        // for each implementation
        // vtable is not allocated on the heap, but is part of `.rodata`
        // (as it is a const inside the struct)
        // we can therefore safely return pointers to this struct from within any fn
        const vtable = VTable{
            .add = addProtoImpl,
            .sub = subProtoImpl,
            .mul = mulProtoImpl,
            .div = divProtoImpl,
        };
    };
    return .{ .ptr = optr, .vtable = &gen.vtable };
}
```

Enter fullscreen mode Exit fullscreen mode

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

[![rabbit profile image](https://zig.news/images/dBswPK1pL-tJB5y4Qmq4tZ9leM92cxL93bO1d1r1W4U/rs:fill:50:50/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS81MzEv/ZTkxNjk2ZDMtOTcw/Zi00MGNiLTkxN2Qt/YWZkMmU1YmI4MTI5/LmpwZw)](https://zig.news/rabbit)

[pylang](https://zig.news/rabbit)

pylang

 [![](https://zig.news/images/Dqc8tqFKbLD32HadGmTHABHUI7AUKh1E7LqKoibm5aM/rs:fill:90:90/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS81MzEv/ZTkxNjk2ZDMtOTcw/Zi00MGNiLTkxN2Qt/YWZkMmU1YmI4MTI5/LmpwZw)pylang](https://zig.news/rabbit)

Follow

-   Joined
    
    12 Jul 2022
    

• [Aug 25](https://zig.news/rabbit/comment/c3)

Dropdown menu

-   [Copy link](https://zig.news/rabbit/comment/c3)

-   Hide

-   [Report abuse](https://zig.news/report-abuse?url=https://zig.news/rabbit/comment/c3)

Determining something at comptime can reduce a lot of stress at runtime

Like comment: Like comment: 2 likes [Comment button Reply](https://zig.news/gowind/but-will-this-blowup--2j5m#/gowind/but-will-this-blowup--2j5m/comments/new/c3)

Collapse Expand

[![thewawar profile image](https://zig.news/images/a3Y781tC4AAs9-wB9D7FGKzon4nBBHBBgTQfGll4d4s/rs:fill:50:50/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS8zODcv/ODViYmYxZDctM2U4/Yy00MTEwLWFjNmIt/YjhkMGY4NmYxN2E5/LmpwZWc)](https://zig.news/thewawar)

[LinFeng](https://zig.news/thewawar)

LinFeng

 [![](https://zig.news/images/TsutV1rmnSgBVND5ajjZWRrfeokZ_UTbKkIGfWRqWiE/rs:fill:90:90/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS8zODcv/ODViYmYxZDctM2U4/Yy00MTEwLWFjNmIt/YjhkMGY4NmYxN2E5/LmpwZWc)LinFeng](https://zig.news/thewawar)

Follow

-   Joined
    
    3 Jan 2022
    

• [Sep 2](https://zig.news/thewawar/comment/cd)

Dropdown menu

-   [Copy link](https://zig.news/thewawar/comment/cd)

-   Hide

-   [Report abuse](https://zig.news/report-abuse?url=https://zig.news/thewawar/comment/cd)

I think it should explicitly add a `comptime` keyword before `const vtable = ...` so that the compiler can put the value in `.rodata`, otherwise it should locate in stack. My point is user should have the option to choose.

Like comment: Like comment: 1 like [Comment button Reply](https://zig.news/gowind/but-will-this-blowup--2j5m#/gowind/but-will-this-blowup--2j5m/comments/new/cd)

[Code of Conduct](https://zig.news/code-of-conduct) • [Report abuse](https://zig.news/report-abuse)

Are you sure you want to hide this comment? It will become hidden in your post, but will still be visible via the comment's [permalink](https://zig.news/gowind/but-will-this-blowup--2j5m#).

Hide child comments as well

Confirm

For further actions, you may consider blocking this person and/or [reporting abuse](https://zig.news/report-abuse)

## Read next

[

![david_vanderson profile image](https://zig.news/images/kwy56Bk-oGbJqj_RUN7pbSd5RDyNIw4wR5m4w1rA-_s/s:100:100/mb:500000/ar:1/aHR0cHM6Ly96aWcu/bmV3cy91cGxvYWRz/L3VzZXIvcHJvZmls/ZV9pbWFnZS8yNi8z/YjBlNTA1NC0zOGM3/LTRhZmUtOTM3MS00/ZmNiY2FjNzBhNGEu/cG5n)

### Faster Interface Style

David Vanderson - Nov 1 '21





](https://zig.news/david_vanderson/faster-interface-style-2b12)[

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





](https://zig.news/sobeston/a-guessing-game-5fb1)
