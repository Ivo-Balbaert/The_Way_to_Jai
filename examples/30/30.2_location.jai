#import "Basic";

code :: #code a := Vector3.{1,2,3};

main :: () { 
    print("In file % line %\n", #file, #line); // (1)
    // => In file d:/Jai/The_Way_to_Jai/examples/30/30.2_location.jai line 4
    print("Filepath is %\n", #filepath);       // (2)
    // => Filepath is d:/Jai/The_Way_to_Jai/examples/30/
    loc := #location(code);                    // (3)
    print("The code is at location %:%\n", loc.fully_pathed_filename, loc.line_number);
    // => The code is at location d:/Jai/The_Way_to_Jai/examples/30/30.2_location.jai:3 
}