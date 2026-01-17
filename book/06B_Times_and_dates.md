# Chapter 6B – Times and dates

Jai uses Apollo Time as its basis for working with time. Defined in module _Basic_, this is a cross-platform time implementation that has both high precision and very long range. Apollo Time is a 128-bit integer, defined as the number of femtoseconds since the Apollo 11 Moon Landing. There are 10e15 femtoseconds in one second.

The common operations like +, - and so on are operator overloaded, and coded in inline assembly for speed.

## 6B.1 - Getting the current time

See *6B.1_Apollo_time.jai*:
```jai
#import "Basic";

main :: () {
    // Apollo time:
    now := current_time_consensus();  // (1)
    print("Now in Apollo Time: %\n", now);

    calendar_utc := to_calendar(now, .UTC);
    print("Calendar UTC in data structure form: %\n", calendar_utc);

    s := calendar_to_string(calendar_utc); // (2)
    print("Date in UTC is:   %\n", s);

    calendar_local := to_calendar(now, .LOCAL);
    s = calendar_to_string(calendar_local);
    print("Date in Local is: %\n", s);

    year := calendar_local.year;
    month := calendar_local.month_starting_at_0 + 1;
    day := calendar_local.day_of_month_starting_at_0 + 1;
    print("[Date \"%1.%2.%3\"]\n", formatInt(year, minimum_digits=4), 
      formatInt(month, minimum_digits=2), formatInt(day, minimum_digits=2));
}

/*
Now in Apollo Time: {745162003441381376, 96639}
Calendar UTC in data structure form: {year = 2026; month_starting_at_0 = 0; day_of_month_starting_at_0 = 14; day_of_week_starting_at_0 = 4; hour = 15; minute = 58; second = 24; millisecond = 701; time_zone = UTC; }
Date in UTC is:   15 January 2026, 15:58:24
Date in Local is: 15 January 2026, 16:58:24
[Date "2026.01.15"]
*/
```

The `to_calendar` proc gives you a struct from which you can extract all useful datetime info. If you just need the current datetime as a string, use to_calendar on this struct as in (2).


## 6B.2 - Measuring time
We measure the time-lapse invoked by calling sleep_milliseconds(100), which suspends execution for 100 ms:


See *6B.2_measuring_time.jai*:
```jai
#import "Basic";

main :: () {
    // _Basic_ time:
    start_time := seconds_since_init();
    sleep_milliseconds(100);
    elapsed := seconds_since_init() - start_time;
    print("Sleep 100 ms took % ms\n", elapsed * 1000); 
    // => Sleep 100 ms took 114.5402 ms
   
    // Apollo time:    
    start := current_time_monotonic();              // (3)
    sleep_milliseconds(100);
    end := current_time_monotonic();
    duration :=  end - start; // (3B)
    // duration := operator - (current_time_monotonic(), start); // (3C)
    print("Sleep 100 ms Apollo took %\n",  duration); 
    // =>  {109085200000000, 0}
    print("%\n",  to_float64_seconds(duration) * 1000 ); 
    // This is 109,0852 ms
}
```

Measuring the time it takes for a procedure or any piece of code to run is as simple as calculating end_time - start_time. This can be done with the Basic function `seconds_since_init()`.

The proc `current_time_monotonic` is called in line (3). 
It returns an instance of Apollo_Time, which is a struct:  

```jai
Apollo_Time :: struct {
    low:  u64;
    high: s64;
}
```
(A monotonic clock is a time source that won't ever jump forward or go backward, due to NTP or Daylight Savings Time updates).

In line (3B), we ask for the current time again, and subtract it from the previous time.This gives us a very accurate way to measure time-spans.

Use `current_time_consensus` as in §6B.1 for getting calendar dates. 
Use `current_time_monotonic` for getting time when doing simulations.

For other examples of Apollo Time, see modules/Basic/examples/time.jai


## 6B.3 - Getting a random number from time
In § 6.2.9 we saw a few routines to get random numbers, however they do repeat the same series of numbers when the program starts again. A better way is to work with a random seed, and what else could be better than a number in femtoseconds like the Apollo time? So this is a good way to get a random number:  

`random_seed(current_time_monotonic().low);`

This proc doesn't return anything, but stores the value in `context.random_state` where it is automatically picked up by the other `random_` procs (see § 25 for Context).

