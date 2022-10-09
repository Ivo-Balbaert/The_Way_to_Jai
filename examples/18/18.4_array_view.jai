#import "Basic";

main :: () {
  static_array := int.[0,1,2,3,4,5];
  arrv : []int = static_array;    // (1)
  print("%\n", arrv.count); // => 6
  print("%\n", arrv[3]);    // => 3
  arrv[3] = 42;
  print("%\n", static_array); // (1B) => [0, 1, 2, 42, 4, 5]
  arrv2: []int = int.[1,2,3,4,5]; // (2)
  print("arrv2 is %\n", arrv2); // => arrv2 is [1, 2, 3, 4, 5]
  a: [..] int;
  for 1..7 array_add(*a, it);  
  v: [] int = a;                  // (3)
  print("v is %\n", v); // => v is [1, 2, 3, 4, 5, 6, 7]

  // create a view on a part of an array, for example from index 2 to 4: [3, 4, 5]
  v.data += 2;
  v.count = 3;
  print("v is %\n", v);  // (4) => v is [3, 4, 5, 6, 7]
  // print("%\n", arrv[6]); // (5)
  // => Array bounds check failed. (The attempted index is 6, but the highest valid index is 5).
}