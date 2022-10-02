// exists in standard library (Basic)
#import "Basic";

is_digit :: (char: u32) -> bool {
    return (char >= #char "0") && (char <= #char "9");
}

main :: () {
    // n := #char "0";
    // print("%", n); // 48
    // m := #char "9";
    // print("%", m); // 57
    // print("%\n\n", #char "5" ); // 53
    
    print("Is 5 a digit? %\n", is_digit(#char "5")); // => true
    print("Is A a digit? %\n", is_digit(#char "A")); // => false
    p := #char "p";
    print("Is p a digit? %\n", is_digit(p)); // => false
}