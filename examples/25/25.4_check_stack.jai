#import "Basic";

#add_context stack_base: *void;     // (1)

init_stack_checker :: () #expand {
    stack_value: u8;
    context.stack_base = *stack_value;
}

is_in_stack :: (pointer: *void) -> bool {
    assert(context.stack_base != null);
    stack_value: u8;
    return pointer > *stack_value && pointer < context.stack_base;
}

main :: () {
    init_stack_checker();       // (2)

    value: int;
    print("value: %\n", is_in_stack(*value));      // => value: true

    external := New(int);       // (3)
    defer free(external);
    print("external: %\n", is_in_stack(external)); // => external: false
}