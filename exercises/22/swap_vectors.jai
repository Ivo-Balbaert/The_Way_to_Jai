#import "Basic";
#import "Math";

main :: () {
    a, b: Vector3;
    a.x, a.y, a.z = 1, 4, 9; 
    b.x, b.y, b.z = 2, 4, 6;
    print("Pre-swap: a is (% % %), b is (% % %)\n", a.x, a.y, a.z, b.x, b.y, b.z);
    Swap(*a, *b);
    print("Post-swap: a is (% % %), b is (% % %)\n", a.x, a.y, a.z, b.x, b.y, b.z);
}
/*
Pre-swap: a is (1 4 9), b is (2 4 6)
Post-swap: a is (2 4 6), b is (1 4 9)
*/