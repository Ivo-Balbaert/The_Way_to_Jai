#import "Basic";

main :: () {
    // Apollo time:
    now := current_time_consensus();  // (1)
    print("Now in Apollo Time: %\n", now);

    calendar_utc := to_calendar(now, .UTC);
    print("Calendar UTC in data structure form: %\n", calendar_utc);

    s := calendar_to_string(calendar_utc);  // (2)
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

