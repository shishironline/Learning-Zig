// adding this line  and 'main' function to please the compiler
const std = @import("std");

// if we add the following code to the file, and try to
// run it, the compiler complains:
// /snap/zig/5732/lib/std/start.zig:563:45: error: struct 'Basics.Basics' has no member named 'main'
//    switch (@typeInfo(@typeInfo(@TypeOf(root.main)).Fn.return_type.?)) {

// constants and variables
//const constant: i32 = 5; //signed 32-bit constant
//var variable: u32 = 5000; //unsigne 32-bit variable

// @as performs an explicit type coercion
//const inferred_constant = @as(i32, 5);
//var inferred_variable = @as(u32, 5000);

// undefined
//const a: i32 = undefined;
// var b: u32 = undefined;

// output when we run it as it is


// Therefore we add a 'main' function to check
// whether our code is correct
// Then we will add the code inside 'main' function
pub fn main() void{

    // assignment
    const constant: i32 = 5; // signed 32-bit constant
    var variable: u32 = 5000; // unsigned 32-bit variable

    // now running it, gives error:
    // Basics.zig:31:9: error: unused local variable
    // var variable: u32 = 5000; // unsigned 32-bit variable
    //    ^~~~~~~~
    // Basics.zig:30:11: error: unused local constant
    // const constant: i32 = 5; // signed 32-bit constant

    //so we print them from 'main' to correct it

    // @as performs forced coercion

    std.debug.print("Hello, {s}!\n", .{"World!"} );

    // std.debug.print(constant);
    // std.debug.print(variable);
    
    // error again
    // (base) shishironline@shishironline:~/Learning-Zig/notes/src$ zig run Basics.zig
    // Basics.zig:46:14: error: expected 2 argument(s), found 1
    // std.debug.print(constant);
    // ~~~~~~~~~^~~~~~
    // /snap/zig/5732/lib/std/debug.zig:89:5: note: function declared here
    // pub fn print(comptime fmt: []const u8, args: anytype) void {
    // ~~~~^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // referenced by:
    // callMain: /snap/zig/5732/lib/std/start.zig:568:17
    // initEventLoopAndCallMain: /snap/zig/5732/lib/std/start.zig:512:51
    // remaining reference traces hidden; use '-freference-trace' to see all reference traces

    std.debug.print(constant, .{});
    std.debug.print(variable, .{});

    // new error: expected type '[]const u8', found 'i32'
    // (base) shishironline@shishironline:~/Learning-Zig/notes/src$ zig run Basics.zig
    // /snap/zig/5732/lib/std/debug.zig:89:23: error: expected type '[]const u8', found 'i32'
    // pub fn print(comptime fmt: []const u8, args: anytype) void {
    
}

