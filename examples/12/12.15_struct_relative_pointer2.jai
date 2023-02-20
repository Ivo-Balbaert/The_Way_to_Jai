#import "Basic";

Node :: struct {
    next: *~s16 Node;
    value: float;
}

main :: () {
    a := Node.{null, 1337};
    b := Node.{null, 42};
    a.next = *b;

    value := a.next.value;  // (1)
    print("rel: %  value: %\n", a.next, value);
    rel_ptr := a.next;

    abs_ptr := cast(*Node) rel_ptr;  // (2)
    print("abs: %  value: %\n", abs_ptr, abs_ptr.value);
    // example output:
    // => rel: r-8 (c6_799d_f7e0)  value: 42
    // => abs: c6_799d_f7e0  value: 42
}