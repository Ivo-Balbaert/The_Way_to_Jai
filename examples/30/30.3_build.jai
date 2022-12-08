#import "Basic";
#import "Compiler";

build :: () {
    w := compiler_create_workspace();                     // (1)
    if !w {
        print("Workspace creation failed.\n");
        return;
    }
    print("The workspace w is %\n", w); // => The workspace is 3

    target_options := get_build_options(w);               // (2)
    target_options.output_executable_name = "program";    // (3)
    set_build_options(target_options, w);                 // (4)
    //  add_build_file("main.jai", w); 
    add_build_file(tprint("%/main.jai", #filepath), w);   // (5)
    set_build_options_dc(.{do_output=false});             // (6)
}

main :: () {
}

#run build();