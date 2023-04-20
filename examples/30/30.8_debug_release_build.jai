#import "Basic";
#import "Compiler";

#run {
    w := compiler_create_workspace("workspace");
    if !w {
        print("Workspace creation failed.\n");
        return;
    }
    target_options := get_build_options(w);
    target_options.output_executable_name = "main3";   
    args := target_options.compile_time_command_line;
    set_build_options(target_options, w);
    for arg: args {       // (1)
        if arg == {
        case "debug";
        build_debug(w);
        case "release";
        build_release(w);
        }
    }
    add_build_file("main3.jai", w);
}

build_debug :: (w: Workspace) {
    print("Choosing debug options...\n");
    target_options := get_build_options(w);
    target_options.backend =.X64; 
    set_optimization(*target_options, Optimization_Type.DEBUG, true);
    set_build_options(target_options, w);
}

build_release :: (w: Workspace) {
    print("Choosing release options...\n");
    target_options := get_build_options(w);
    target_options.backend = .LLVM;
    set_optimization(*target_options, Optimization_Type.VERY_OPTIMIZED);   
    set_build_options(target_options, w);
}

main :: () {}