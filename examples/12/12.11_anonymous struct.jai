#import "Basic";

state: struct {
    a, b: int;
};


main :: () {
    some_function :: () {
        state.a = 4;
    }

    some_function();
    print("state is: % - %", state.a, state.b); // => state is: 4 - 0
}

