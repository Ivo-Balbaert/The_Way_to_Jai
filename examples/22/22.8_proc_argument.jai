#import "Basic";
#import "Math";

square_and_print :: (v: *Vector3) {     
    v.x *= v.x;
    v.y *= v.y;
    v.z *= v.z;
    print("v is %, %, %\n", v.x, v.y, v.z);
} 

do_three_times :: (proc: (*Vector3), arr: *Vector3) {  // (1)
    for 1..3 proc(arr);
}

main :: () {
    v := Vector3.{1.1, 10, 0.5};
    do_three_times(square_and_print, *v);   // (2)
}

/*
v is 1.21, 100, 0.25
v is 1.4641, 10000, 0.0625
v is 2.143589, 100000000, 0.003906
*/