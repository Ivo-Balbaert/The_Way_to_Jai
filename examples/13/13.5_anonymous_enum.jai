#import "Basic";

state: enum {
    A;
    B;
};

main :: () {
    some_function :: () {
        state = .B;
    }

    some_function();
    print("state is: %", state); // => state is: B
}