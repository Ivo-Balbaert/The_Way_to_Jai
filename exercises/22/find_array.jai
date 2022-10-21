#import "Basic";

find :: (arr: [] $T, item: T) -> s64 {
  for arr if it == item return it_index;
  return -1; // Not found
}

main :: () {
  arr: [4] float32;
  arr[0] = 4.5;
  arr[1] = 4.2;
  arr[2] = 4.3;
  arr[3] = 10.0;

  index := find(arr, 4.2);
  print("index of 4.2 is %\n", index); // => index of 4.2 is 1
  index = find(arr, 6.9);
  print("index of 6.9 is %\n", index); // => index of 6.9 is -1
}