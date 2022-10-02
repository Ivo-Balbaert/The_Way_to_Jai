#import "Basic";

assert :: (b: bool) {
    if b return;
    print("Condition % : ******* ASSERTION FAILED *******\n", b);
}

main :: () {
    assert (1 == 1);
    assert (1 == 3);  // => Condition false : ******* ASSERTION FAILED *******
    assert (3 == 3.0);
}

