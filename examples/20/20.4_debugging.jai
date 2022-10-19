#import "Basic";
Debug :: #import "Debug";

ac := "Budapest";

main :: () {
    print("ac: %\n", ac);
    ac = "Tokyo";
    print("ac: %\n", ac);
    n := 3;
    m := 7;
    Debug.attach_to_debugger();     // (1)
    Debug.breakpoint();             // (2)
    for 1..4 {
        n += 1;
        m += n * 2;
        if m == 37      Debug.breakpoint();             // (3)
        print("\n% after % times", m, it);
    }
    print("\n\n");
    print("%\n", n);  // => 7
    print("%\n", m);  // => 51
}

/* 
ac: Budapest
ac: Tokyo
15 after 1 times
25 after 2 times
37 after 3 times
51 after 4 times

7
51
*/

