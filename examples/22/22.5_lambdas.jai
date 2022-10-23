#import "Basic";

add100 :: (a: []int, proc: (int) -> int) -> []int {  // (1)
    result: [..]int;
    for a   array_add(*result, proc(a[it_index]));   // (2)
    return result;
}

main :: () {
  array_a := int.[1, 2, 3, 4, 5, 6, 7, 8];
  array_b := add100(array_a, (x) => x + 100);        // (3)
  // lam :: (x) => x + 100;                          // (4)
  // array_b := add100(array_a, lam);                // (5)
  print("%\n", array_b); // => [101, 102, 103, 104, 105, 106, 107, 108]
  defer array_free(array_b);
}

