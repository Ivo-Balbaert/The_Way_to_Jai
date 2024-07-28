#import "Basic";
#import "Math";

macro0 :: () #expand { }   // (1)

macro1 :: () #expand {
    a := "No backtick";    // (1B) 
    print("a at macro1 start is: %\n", `a); //   (4A) => a at macro1 start is: 0
    `a += 10;              //  (2) 
}

maxm :: (a: int, b: int) -> int #expand {  // (5)
    if a > b then return a;
    return b;
}

macro2 :: () -> int #expand {   // (6)
    if `b < `c {
      return 0;
    }
    defer print("Defer inside macro2\n"); // (6B) // => Defer inside macro2
    // `defer print("`Defer inside macro2\n"); // (6C) // => `Defer inside macro2
    return 1;
}

macro3 :: () #expand {
    nested_macro :: () #expand {
      print("This is a nested macro\n");
    }

    print("This is macro3\n");
    `c = 108;
    nested_macro();
}

factorial :: (n: int) -> int #expand {
    #if n <= 1 return 1;
    else {
      return n * factorial(n-1);
    }
}

macfunc :: () -> string {
    macron :: () -> int #expand {
        defer print("Defer inside macron\n");  // (7)
        if `a < `b {
            `return "Backtick return macron\n"; 
        }
        return 1;
    }

    a := 0;
    b := 100;
    print("In maxfunc just before calling macron\n"); 
    c := macron();
    print("In maxfunc just before returning\n");  // never printed!
    return "none";
}

macroi :: (c: Code) #expand {   // (9)
    #insert c;
    #insert c;
    #insert c; 
}

main :: () {
    a := 0;
    macro1(); // (3)
    print("a is: %\n", a); // (4B) => a is: 10

    b := 7;
    c := 3;
    print("max is %\n", maxm(b, c)); // => max is 7

    print("macro2 returns %\n", macro2()); // => macro2 returns 1

    macro3();
    // => This is macro3
    // => This is a nested macro
    print("c is %\n", c); // => c is 108


    x := factorial(5);
    print("factorial of 5 = %\n", x); // => factorial of 5 = 120

    s := macfunc();  
    // => In maxfunc just before calling macron
    // => Defer inside macron
    print("%\n", s); // (8) => Backtick return macron 

    va := Vector3.{1,2,3};
    code :: #code print("% - ", va);
    macroi(code); // => {1, 2, 3} - {1, 2, 3} - {1, 2, 3} -
}

/* with defer in macro 2:
a at macro1 start is: 0
a is: 10
max is 7
Defer inside macro2
macro2 returns 1
This is macro3
This is a nested macro
c is 108
factorial of 5 = 120
In maxfunc just before calling macron
Defer inside macron
Backtick return macro
{1, 2, 3} - {1, 2, 3} - {1, 2, 3} -
*/

