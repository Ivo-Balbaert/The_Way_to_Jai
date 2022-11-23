#import "Basic";

// Self_Referential :: struct {     // (1)
//     pointer: *Self_Referential;
//     other:   *Self_Referential;
// }

Self_Referential :: struct {        // (2)
    pointer: *#this;
    other:   *#this;
}

main :: () {
    ref: Self_Referential;
    print("ref is %\n", ref);   // (3) => ref is {null, null}
    ref.pointer = *ref;
    ref.other = ref.pointer;
    print("ref is %\n", ref);   // (4) => ref is {a8_756f_f650, a8_756f_f650}
}