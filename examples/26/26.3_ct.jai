#import "Basic";

main :: () {
    print("#compile_time is %\n", #compile_time); // => #compile_time is false

    if #compile_time {
        #run print("compile time.\n");
    } else {
        print("not compile time.\n"); // => not compile time
    }
}

#run main(); // => #compile_time is true