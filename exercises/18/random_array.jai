#import "Basic";
#import "Random";


main :: () {
    arr: [16] u64;
    for i: 0..15      arr[i] = random_get() % 100;
    print("%\n", arr); // => [6, 58, 26, 83, 78, 91, 83, 73, 89, 92, 56, 77, 92, 90, 48, 52]
}


