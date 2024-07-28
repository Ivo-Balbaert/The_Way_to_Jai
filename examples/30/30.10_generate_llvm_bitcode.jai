#import "Basic";
#import "Compiler";

#run {
    w := compiler_create_workspace();
    if !w {
        print("Workspace creation failed.\n");
        return;
    }
    target_options := get_build_options(w);
    target_options.output_executable_name = "exec";
    target_options.intermediate_path = #filepath;
    set_optimization(*target_options, Optimization_Type.OPTIMIZED);  // (1)
    target_options.llvm_options.output_bitcode = true;  // (2)
    set_build_options(target_options, w);

    // compiler_begin_intercept(w);
    add_build_file("main.jai", w);  

    // while true {
    //     message := compiler_wait_for_message();
    //     if !message break;
    //     if message.kind == {
    //     case .COMPLETE;
    //     break;
    //     }
    // }
    // compiler_end_intercept(w);
    set_build_options_dc(.{do_output=false});  
}