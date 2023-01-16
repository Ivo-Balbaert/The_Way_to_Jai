#import "Basic";

fun :: (x: int) -> first := "Hello", second := "Sailor!" {
    if x == 0 return;
    if x == 1 return "Simple";
    if x == 2 return "Simple", "Simon";
    if x == 3 return second = "Simple", first = "Simon";

    return second = "Dolly";
}


main :: () {
    a, b: string;
    a, b = fun(0); 
    print("1 % %\n", a, b); 
    a, b = fun(1);
    print("2 % %\n", a, b); 
    a, b = fun(2); 
    print("3 % %\n", a, b); 
    a, b = fun(3); 
    print("4 % %\n", a, b); 
    a, b = fun(4); 
    print("5 % %\n", a, b); 
}

/*
1 Hello Sailor!
2 Simple Sailor!
3 Simple Simon
4 Simon Simple
5 Hello Dolly
*/