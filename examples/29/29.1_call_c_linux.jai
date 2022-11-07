// This program only works on Linux!
#import "Basic";

libc :: #foreign_system_library "libc"; 

// C-functions:
strlen :: (s: string) -> int                     #foreign libc;
printf :: (s: string, args: ..[] Any) -> int     #foreign libc;
rand :: () -> s64                                #foreign libc;
clock :: () -> s64                               #foreign libc;

main :: () {
   print("%\n", rand());  // => 1804289383
   print("%\n", clock()); // => 2446
}