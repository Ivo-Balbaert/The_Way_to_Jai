#import "Basic";
#import "Compiler";

build :: () {
    w := compiler_create_workspace();                     
    if !w {
        print("Workspace creation failed.\n");
        return;
    }
    print("The current workspace is %\n", w); // => The current workspace is 3

    target_options := get_build_options(w);               
    target_options.output_executable_name = "program";    
    set_build_options(target_options, w);                 

    compiler_begin_intercept(w);     // (1)

    add_build_file(tprint("%/main.jai", #filepath), w);   
    
    while true {                     // (2)          
        message := compiler_wait_for_message();  // (3)
        print(" >> %\n", <<message); // (4) => see output below
        if !message break;
        if message.kind == {
            case .COMPLETE;          // (5)
            break;
        }
    }
    compiler_end_intercept(w);       // (1B)
}

main :: () {}

#run build();

/*
>> {IMPORT, 3}
 >> {FILE, 3}
 ...
 >> {PHASE, 3}
 >> {TYPECHECKED, 3}
 ...
 >> {PHASE, 3}
Running linker: 
 >> {PHASE, 3}

Stats for Workspace 3 (unnamed):
 >> {COMPLETE, 3}
 */