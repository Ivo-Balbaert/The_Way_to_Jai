#import "Basic";

Holder :: struct (N: int, T: Type)
#modify { if N < 8 N = 8;  return true; }
{
    values: [N] T;
}

main :: () {
    a: Holder(9, float);
    b: Holder(3, float);
    print("b is %\n", b); // => b is {[0, 0, 0, 0, 0, 0, 0, 0]}
    assert(b.N >= 8); 
}
