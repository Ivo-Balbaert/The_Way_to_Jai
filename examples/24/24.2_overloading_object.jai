#import "Basic";

Obj :: struct {     
    array: [10]int;
}

operator [] :: (obj: Obj, i: int) -> int {       // (1)
    return obj.array[i];
}

operator []= :: (obj: *Obj, i: int, item: int) { // (2)
    obj.array[i] = item;
}

operator *[] :: (obj: *Obj, i: int) -> *int {    // (3)
    return *obj.array[i];
}

operator *= :: (obj: *Obj, scalar: int) {        // (4) 
    for obj.array  obj.array[it] *= scalar;
// alternative:
//     for *a: obj.array  { <<a *= scalar; }
}

main :: () {
    o : Obj;
    print("o[0] = %\n", o[0]);  // (1B) => o[0] = 0
    o[0] = 10;                  // => o[0] = 10
    print("o[0] = %\n", o[0]);

    p : Obj;
    p.array = .[0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    p *= 100;                  // (4B)
    print("p.array = %\n", p.array);  
    // => p.array = [0, 100, 200, 300, 400, 500, 600, 700, 800, 900]

    ptr := *p[7];              // (3B)
    print("<<ptr is %\n", <<ptr); // => <<ptr is 700
    <<ptr *= 3;
    print("<<ptr is %\n", <<ptr); // => <<ptr is 2100
    print("p[7] is %\n", p[7]);   // => p[7] is 2100
}


