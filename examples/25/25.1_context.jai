#import "Basic";

#add_context this_is_the_way := true;   // (1)

main :: () {
    str := "Hello, Sailor!";
    new_context: Context;               // (2)
    push_context new_context {          // (3)
        // Do things within this new context.
        push_allocator(temp);           // (4)
    }
    log(str);   // (5) => Hello, Sailor!
}
