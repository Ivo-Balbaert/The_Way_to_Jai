#import "Basic";

map :: (array_a: [$N] $T, f: (T)-> T ) -> [N] T {
  array_b: [N]T;
  for i: 0..N-1 {
    array_b[i] = f(array_a[i]);
  }
  return array_b;
}

main :: () {
  array_a := int.[1, 2, 3, 4, 5, 6, 7, 8];
  array_b := map(array_a, (x) => x + 100); 
  print("array_b is %\n", array_b);
  // => array_b is [101, 102, 103, 104, 105, 106, 107, 108]
}

