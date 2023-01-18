#import "Basic";
#import "Random";

bubble_sort :: (arr: [] $T, compare_code: Code) #expand {
  for 0..arr.count-1 {
    for i: 1..arr.count-1 {
      a := arr[i-1];
      b := arr[i];
      if !(#insert,scope() compare_code) { // arr[i-1] > arr[i], so swap them
        t := arr[i];
        arr[i] = arr[i-1];
        arr[i-1] = t;
      }
    }
  }
}

main :: () {
    arr: [10] int;

    arr = .[23, -89, 54, 108, 42, 7, -2500, 1024, 666, 0];
    bubble_sort(arr, #code (a <= b));
    print("sorted array: %\n", arr);
    // => sorted array: [-2500, -89, 0, 7, 23, 42, 54, 108, 666, 1024]

    for i: 0..9  arr[i] = cast(int) random_get() % 100;
    bubble_sort(arr, #code (a < b));
    print("sorted array: %\n", arr);
    // => sorted array: [-58, -43, -33, -33, -25, 6, 26, 78, 89, 92]
}