#import "Basic";

main :: () {
    print("System time: %\n",  get_system_time());      // (1)
    // => System time: {year = 2023; month = 1; day_of_week = 6; day = 7; hour = 10; minute = 11; second = 3; millisecond = 439; }
    print("System time local:  %\n",  get_system_time(true));
    // => System time local:  {year = 2023; month = 1; day_of_week = 6; day = 7; hour = 11; minute = 11; second = 3; millisecond = 439; }
    print("Hour: %\n",  get_system_time(true).hour);    // => 11

    // Apollo time:
    now := current_time_consensus();  // (2)
    print("Now in Apollo Time: %\n", now);

    calendar_utc := to_calendar(now, .UTC);
    print("Calendar UTC in data structure form: %\n", calendar_utc);

    s := calendar_to_string(calendar_utc);
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

