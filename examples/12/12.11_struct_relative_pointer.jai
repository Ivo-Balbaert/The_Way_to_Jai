#import "Basic";

Holder :: struct {
    a: *~s16 float;     // (1)
    b: float;
}

make_holder :: (value: float) -> *Holder {
    holder := New(Holder);
    holder.a = *holder.b;   // (2)
    holder.b = value;
    
    return holder;
}

main :: () {
    holder := make_holder(42.42);
    print("    holder is: %\n", holder); // => holder is: 200_3893_57a0
    print("    type_of(holder.a) is: %\n", type_of(holder.a));
    // => type_of(holder.a) is: *~s16 float32

    pointer_from_stack := holder.a;  // (3) 
    print("    type_of(pointer_from_stack) is: %\n", type_of(pointer_from_stack));
    // =>  type_of(pointer_from_stack) is: *float32
    print("    Dereferencing pointer_from_stack: %\n", << pointer_from_stack);
    // (4) => Dereferencing pointer_from_stack: 42.419998
 }  