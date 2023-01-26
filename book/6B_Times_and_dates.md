# Chapter 6B – Times and dates

Jai uses Apollo Time as its basis for working with time. It is defined in module _Basic_, and is a cross-platform time implementation that has both high precision and very long range. Apollo Time is a 128-bit integer, defined as the number of femtoseconds since the Apollo 11 Moon Landing. There are 10**15 femtoseconds in one second.

The common operations like +, - and so on are operator overloaded, and coded in inline assembly for speed.

## 6B.1 - Getting the current time

See *6B.1_times.jai*:
```c++
#import "Basic";

main :: () {
    init_time();
    print("System time: %\n",  get_system_time());      // (1)
    // => System time: {year = 2023; month = 1; day_of_week = 6; day = 7; hour = 10; minute = 11; second = 3; millisecond = 439; }
    print("System time local:  %\n",  get_system_time(true));
    // => System time local:  {year = 2023; month = 1; day_of_week = 6; day = 7; hour = 11; minute = 11; second = 3; millisecond = 439; }
    print("Hour: %\n",  get_system_time(true).hour);    // => 11

    print("Get time: %\n",  get_time());      // (1B) => Get time: Get time: 0.000634

    // Apollo time:
    now := current_time_consensus();  // (2)
    print("Now in Apollo Time: %\n", now);

    calendar_utc := to_calendar(now, .UTC);
    print("Calendar UTC in data structure form: %\n", calendar_utc);

    s := calendar_to_string(calendar_utc); // (2B)
    print("Date in UTC is:   %\n", s);

    calendar_local := to_calendar(now, .LOCAL);
    s = calendar_to_string(calendar_local);
    print("Date in Local is: %\n", s);

    a := current_time_monotonic();              // (3)
    print("%\n", a);
    a = operator - (current_time_monotonic(), a); // (3B)
    print("%\n", a);
}

/*
System time: {year = 2023; month = 1; day_of_week = 6; day = 7; hour = 10; minute = 30; second = 40; millisecond = 631; }
System time local:  {year = 2023; month = 1; day_of_week = 6; day = 7; hour = 11; minute = 30; second = 40; millisecond = 631; }
Hour: 11
Now in Apollo Time: {2041441820542339328, 91467}
Calendar UTC in data structure form: {year = 2023; month_starting_at_0 = 0; day_of_month_starting_at_0 = 6; day_of_week_starting_at_0 = 6; hour = 10; minute = 30; second = 40; millisecond = 631; time_zone = UTC; }
Date in UTC is:   7 January 2023, 10:30:40
Date in Local is: 7 January 2023, 11:30:40
{6197379770900000000, 0}
{120700000000, 0}
*/
```
`get_system_time` used in line (4) gives you the time as a struct, from which you can extract every time item such as day or hour.
`get_time`  returns the time in seconds since the call to init_time(). We use it in the next section to measure performance of a piece of code .

The rest of the examples uses Apollo Time. The `to_calendar` proc gives you a struct from which you can extract all useful datetime info. If you just need the current datetime as a string, use to_calendar on this struct as in (2B).

The proc `current_time_monotonic` is called in line (3). 
It returns an instance of Apollo_Time, which is a struct:  ptr

```c++
Apollo_Time :: struct {
    low:  u64;
    high: s64;
}
```
( A monotonic clock is a time source that won't ever jump forward or go backward, due to NTP or Daylight Savings Time updates ).

In line (3B), we ask for the current time again, and subtract it from the previous time.This gives us a very accurate way to measure time-spans.

(For other examples of Apollo Time, see modules/Basic/examples/time.jai)


## 6B.2 - Measuring performance using get_time
The `get_time` proc from module _Basic_ returns a time in seconds since init_time() was called; it will call init_time if it hasn't been called. `get_time` uses the system timers  (the OS performance counters) for measuring time. It is useful for calculating time differences (as in line (1) below), so it can give a measure of performance of a certain proc or part of the program.  
For more accurate results, use Apollo time `current_time_monotonic()` as discussed in the previous section.

See *6B.2_get_time.jai*:
```c++
#import "Basic";

factorial :: (n: int) -> int {
    if n <= 1  return 1;
    return n * factorial(n-1);
}

main :: () {
    start_time := get_time();
    print("Factorial 20 is %\n", factorial(20)); 
    // => Factorial 20 is 2432902008176640000
    elapsed := get_time() - start_time;
    print("Factorial 20 took % ms\n", elapsed * 1000);
    // => Factorial 20 took 0.1857 ms
}
```

`factorial` is a recursive (see § 17.9) procedure to compute:  
factorial(n) = n * (n-1) * (n-2) * ... 3 * 2 * 1.
See an example of use in § 31.2.2

## 6B.3 - Getting a random number from time
In § 6.2.9 we saw a few routines to get random numbers, however they do repeat the same series of numbers when the program starts again. A better way is to work with a random seed, and what else could be better than a number in femtoseconds like the Apollo time? So this is a good way to get a random number:  

`random_seed(current_time_monotonic().low);`

This proc doesn't return anything, but stores the value in `context.random_state` where it is automatically picked up by the other `random_` procs (see § 25 for Context).

