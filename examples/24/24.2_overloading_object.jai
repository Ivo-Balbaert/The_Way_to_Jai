#import "Basic";

Obj :: struct {     
  array: [10]int;
}

operator [] :: (obj: Obj, i: int) -> int {  // (1)
  return obj.array[i];
}

operator *= :: (obj: *Obj, scalar: int) {   // (2) 
    for obj.array  obj.array[it] *= scalar;
// alternative:
//     for *a: obj.array  { <<a *= scalar; }
}

main :: () {
  o : Obj;
  print("o[0] = %\n", o[0]);  // (1B) => o[0] = 0

  o2 : Obj;
  o2.array = .[0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  o2 *= 100;                  // (2B)
  print("o2.array = %\n", o2.array);  
  // => o2.array = [0, 100, 200, 300, 400, 500, 600, 700, 800, 900]
}