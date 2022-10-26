#import "Basic";

CONSTANT :: 3;

main :: () {
    print("The operating system is %\n", OS); // (1) => The operating system is WINDOWS
    #if OS == .WINDOWS {                      // (2)
        print("I'm on Windows!\n");           // (3) => I'm on Windows!
    }   

    #if OS == .LINUX {
        print("I'm on Linux!\n");
    }

    #if CONSTANT == 0 {                       // (4)
    }   else #if CONSTANT == 1 {
    }   else #if CONSTANT == 2 {
    }   else {  
        print("CONSTANT is %\n", CONSTANT); // => CONSTANT is 3
    }
}
