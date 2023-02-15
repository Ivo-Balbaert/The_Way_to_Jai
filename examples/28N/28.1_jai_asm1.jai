#import "Basic";

main :: () {
    count := 10;          // (1)

    #asm {
        add count, 17;    // (2)
    }

    print("count is %\n", count); // => count is 27
}