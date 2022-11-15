# Chapter 6B – Times and dates

Jai uses Apollo Time as its basis for working with time. It is defined in module _Basic_, and is a cross-platform time implementation that has both high precision and very long range. Apollo Time is a 128-bit integer, defined as the number of femtoseconds since the Apollo 11 Moon Landing. There are 10**15 femtoseconds in one second.

The common operations like +, - and so on are operator overloaded, and coded in inline assembly for speed.

## 6B.1 - Getting the current time

See _6B.1_times.jai_:
```c++
#import "Basic";
#import "Random";

main :: () {
    a := current_time_monotonic();              // (1)
    print("%\n", a);
    a = operator-(current_time_monotonic(), a); // (2)
    print("%\n", a);

    r := random_seed(current_time_monotonic().low); // (3)
    print("%\n", r); // => void
}

/*
{155922876271345152, 3}
{313400000000, 0}
void
*/```

The proc `current_time_monotonic` is called in line (1). 
It returns an instance of Apollo_Time, which is a struct:  ptr

```c++
Apollo_Time :: struct {
    low:  u64;
    high: s64;
}
```

( A monotonic clock is a time source that won't ever jump forward or go backward, due to NTP or Daylight Savings Time updates ).

In line (2), we ask for the current time again, and subtract it from the previous time.This gives us a very accurate way to measure time-spans.

## 6B.2 - Getting a random number from time
In § 6.2.9 we saw a few routines to get random numbers, however they do repeat the same series of numbers when the program starts again. A better way is to work with a random seed, and what else could be better than a number in femtoseconds like the Apollo time? So this is a good way to get a random number:  

`random_seed(current_time_monotonic().low);`

This proc simply stores the value in `context.random_state` for further use (see § 25 for Context).