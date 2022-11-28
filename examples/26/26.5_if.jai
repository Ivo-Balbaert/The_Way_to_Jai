#import "Basic";
#import "Math";

CONSTANT :: 3;

ENABLE_EXTRA_MODES :: true;

Log_Mode :: enum {
    NONE;           
    MINIMAL;        
    EVERYDAY;       
    VERBOSE;

    #if ENABLE_EXTRA_MODES {           // (5)
            VERY_VERBOSE;
            SECRET;
            TOP_SECRET;
    }       
}

IS_PATIENT :: true;

Person :: struct {
    name            : string;
    age             : int;
    location        : Vector2;

    #if IS_PATIENT  disease := "common cold"; // (6)
}

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

    name := #ifx OS == .WINDOWS then "Microsoft Windows"; else "Linux"; // (7)
    print("name is %\n", name); // => name is Microsoft Windows
}
