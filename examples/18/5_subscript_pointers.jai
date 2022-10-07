#import "Basic";

main :: () {
    array : [128] int;
    for * array  {<<it = it_index;}

    ptr : *int = array.data;
    print("% %\n", ptr[100], ptr[101]);  // => 100 101
}