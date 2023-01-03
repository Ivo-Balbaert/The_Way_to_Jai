#import "Basic";
#import "Sort";
#import "String";

main :: () {
    arrf := float.[8, 108, 42, 5, 3.14, 17, -5, -272];
    arrs := string.["the", "quick", "brown", "fox", "jumped", "over", "the", "lazy", "dog"];

    quick_sort(arrf, compare_floats);
    print("arrf quick-sorted is %\n", arrf); 
    // => [-272, -5, 3.14, 5, 8, 17, 42, 108]

    quick_sort(arrs, compare_strings);
    print("arrs quick-sorted is %\n", arrs); 
    // => arrs quick-sorted is ["brown", "dog", "fox", "jumped", "lazy", "over", "quick", "the", "the"]

    arrf1 := float.[8, 108, 42, 5, 3.14, 17, -5, -272];
    arrs1 := string.["the", "quick", "brown", "fox", "jumped", "over", "the", "lazy", "dog"];

    bubble_sort(arrf1, compare_floats);
    print("arrf1 bubble-sorted is %\n", arrf1); 
    // => [-272, -5, 3.14, 5, 8, 17, 42, 108]

    bubble_sort(arrs1, compare);
    print("arrs1 bubble-sorted is %\n", arrs1); 
    // => ["brown", "dog", "fox", "jumped", "lazy", "over", "quick", "the", "the"]
}