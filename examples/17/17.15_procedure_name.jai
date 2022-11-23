#import "Basic";

add :: (x: int, y: int) -> int {
    print("The proc name is: %", #procedure_name());
    return x + y;
}
main :: () {
    print("The main name is: %\n", #procedure_name());
    // => The main name is: main
    add(2, 3); // => The proc name is: add
}