#import "Basic";
#import "String";
#import "System";

main :: () {
    exe_path := get_path_of_running_executable();  // (1)
    print("exe path is: %\n", exe_path);
    // exe path is: D:/Jai/The_Way_to_Jai/examples/27/27.exe

    path := path_strip_filename(exe_path);         // (2)
    print("path is %\n", path);
    // => path is D:/Jai/The_Way_to_Jai/examples/27/

    set_working_directory(path);                   // (3)
}