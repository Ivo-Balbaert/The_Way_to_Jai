#import "Basic";
#import "Compiler";
// (1)
TARGET_PROGRAM_TEXT :: #string DONE                
#import "Basic";

main :: () {
    print("This program was built with metaprogram 30.3B_build_add_build_string.jai\n");
}
DONE

build :: () {
    w := compiler_create_workspace();                     
    target_options := get_build_options(w);             
    target_options.output_executable_name = "build_string";    
    set_build_options(target_options, w);                 
    add_build_string(TARGET_PROGRAM_TEXT, w);       // (2)
    set_build_options_dc(.{do_output=false});        
}

main :: () {
}

#run build();