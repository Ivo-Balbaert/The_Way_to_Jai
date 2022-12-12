#import "Basic";

Package :: struct {             
    strings: [3] string~s8;   // (15) 
    string_data: [100] u8;
}

main :: ()  {
    str: string = "Hello."; // (0) same as: str := "Hello.";
    a := "Happy";
    print("a's length is %\n", a.count); // (1) => a's length is 5
    print("a's data starts at % with value %\n", a.data, << a.data); // (2)
    // => a's data starts at 7ff7_d2ed_2007 with value 72
    
    ch := "世界"; // (3)
    print("ch's length is %\n", ch.count); // => ch's length is 6
    print("ch's data starts at % with value %\n", ch.data, << ch.data); //
    // (4) => ch's data starts at 7ff7_fceb_6409 with value 228

    print(str); // => Hello.
    print("The 5th character of str is: % \n", str[5]); // (5)
    // => The 5th character of str is: 46
    // str[5] = #char "!"; // (6) run-time crash of program
    /*
     The program crashed. Printing the stack trace:
     handle_exception      c:\jai\modules\Runtime_Support_Crash_Handler.jai:211
     ... (skipping OS-internal procedures)
     main                  d:\Jai\The_Way_to_Jai\examples\19\19.1_strings.jai:18  
    */
    // str[5] = "!"; // Error: Type mismatch. Type wanted: u8; type given: string.
    // str[5] = '!'; // Error: Unable to parse an expression to the right of this binary operator.

    // Bounds checking:
    // print("The 99th character of str is: % \n", str[99]); // (7) => 
    /*
    Panic.
    The program crashed. Printing the stack trace:
    handle_exception                  c:\jai\modules\Runtime_Support_Crash_Handler.jai:211
    ... (skipping OS-internal procedures)
    debug_break                       c:\jai\modules\Runtime_Support.jai:8
    my_panic                          c:\jai\modules\Runtime_Support.jai:136
    __array_bounds_check_fail         c:\jai\modules\Runtime_Support.jai:185
    main                              d:\Jai\The_Way_to_Jai\examples\19\19.1_strings.jai:23
    */

    // implicit cast of string to bool:
    if str {            // (8)
        print("string is not empty!"); // => string is not empty!
    } else {
        print("string is empty!");
    }

    // (9)
    multi_line_string := #string END
    This
        is
      a
            multi-line
    string.
    END;

    print(multi_line_string);
    /*
    This
        is
      a
            multi-line
    string.
    */

    // Looping over the characters in a string:
    for i: 0..str.count-1 {             // (10)
            print("% -", str[i]);
    } // => 72 -101 -108 -108 -111 -46 -
    print("\n");
    for i: 0..ch.count-1 {
            print("% -", ch[i]);
    } // => 228 -184 -150 -231 -149 -140
    print("\n");
    for cast([] u8) str {             // (10B)
        print("% -", it);
    } // => 72 -101 -108 -108 -111 -46 -

    // sprint:
    b := "Resounding ";
    newstr := sprint("% %!\n", b, ch); // (11)
    print("%\n", newstr); // => Resounding 世界!
    free(newstr);  // (12)

    // Changing string data:
    // with sprint:
    chg_str := sprint("%", str);      // (12B)
    print("chg_str is %\n", chg_str); // => chg_str is Hello.
    for i: 0..chg_str.count - 1 {
       if chg_str[i] == #char "."  chg_str[i] = #char "?";
    }
    print("chg_str after for is %\n", chg_str); // => chg_str is Hello?
    free(chg_str);
    // in stack memory:
    SIZE :: "Hello.".count;
    mem : [SIZE]u8;
    memcpy (mem.data, str.data, str.count);  // (12C)
    chg_str2 := to_string (mem.data, mem.count);
    print("chg_str2 is %\n", chg_str2); // => chg_str2 is Hello.
    for i: 0..chg_str2.count - 1 {
       if chg_str2[i] == #char "."  chg_str2[i] = #char "?";
    }
    print("chg_str2 after for is %\n", chg_str2); // => chg_str2 is Hello?
    // allocate on the heap:
    chg_str3 := copy_string (str);          // (12D)
    defer(free(chg_str3));
    print("chg_str3 is %\n", chg_str3); // => chg_str3 is Hello.
    for i: 0..chg_str3.count - 1 {
       if chg_str3[i] == #char "."  chg_str3[i] = #char "?";
    }
    print("chg_str3 after for is %\n", chg_str3); // => chg_str3 is Hello?

    // strings are array views:
    x := "Sailor";  // (13)
    x.count = 4;
    print("x is: '%'\n", x);    // => x is: 'Sail'
    x.count -= 1;
    x.data += 1; // <-- pointer advances 1 byte, and now points to 'a'
    print("x is: '%'\n", x);    // => x is: 'ail'

    length := 108;
    buffer := cast(*u8) alloc(length);     // (14)
    // fill up buffer in some way or other, 
    strdata: string;           
    strdata.data = buffer;
    strdata.count = length;
}