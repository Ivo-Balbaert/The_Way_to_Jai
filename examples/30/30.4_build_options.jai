#import "Basic";
#import "Compiler";

build :: () {
    w := compiler_create_workspace();
    if !w {
        print("Workspace creation failed.\n");
        return;
    }
    target_options := get_build_options(w);

    target_options.optimization_level = .DEBUG;   

    target_options.backend = .LLVM;               

    target_options.output_type = .EXECUTABLE;      
    target_options.output_executable_name = "my_program";
    
    target_options.stack_trace = false;
    target_options.backtrace_on_crash = .OFF;

    target_options.array_bounds_check = .ON; // values: .OFF / .ON / .ALWAYS
    target_options.cast_bounds_check  = .FATAL; 
    target_options.null_pointer_check = .ON; 
    
    target_options.runtime_storageless_type_info = true;

    format := *context.print_style.default_format_struct;  // (1)
    format.use_newlines_if_long_form = true;
    format.indentation_width = 4;  
    print("Build_Options for Workspace % are: %\n", w, target_options);

    set_build_options(target_options, w);
    set_build_file_path("./");  // output executable in current folder (= default)
    
    add_build_file("main.jai", w);
}

main :: () {}

#run build();

/*
Build_Options for Workspace 3 are: {
    output_type = EXECUTABLE;
    Commonly_Propagated = {
        optimization_level = DEBUG;
        write_added_strings = true;
        runtime_storageless_type_info = true;
        shorten_filenames_in_error_messages = false;
        use_visual_studio_message_format = false;
        use_natvis_compatible_types = false;
        minimum_macos_version = {10, 14};
        use_custom_link_command = false;
        lazy_foreign_function_lookups = false;
        disable_redzone = false;
        enable_bytecode_inliner = false;
        stack_trace = false;
        enable_auto_dereference = true;
        use_ansi_color = true;
        interactive_bytecode_debugger = false;
        enable_frame_pointers = true;
        array_bounds_check = ON;
        cast_bounds_check = FATAL;
        math_bounds_check = NONFATAL;
        null_pointer_check = ON;
        dead_code_elimination = MODULES_ONLY;
        backtrace_on_crash = OFF;
        info_flags = 0;
        text_output_flags = OUTPUT_LINK_LINE | OUTPUT_TIMING_INFO;
        os_target = WINDOWS;
        backend = LLVM;
        machine_type = (enum out of range: 95);
        machine_options = [108, 105, 98, 16, 129, 136, 6, 1, 34, 216, 66, 0, 0, 0, 0, 0, 0, 0, 40, 33, 1, 0, 0, 0, 0, 0, 0, 8, 1, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0...];
        emit_debug_info = DEFAULT;
        maximum_polymorph_depth = 100;
        maximum_array_count_before_compile_time_returns_are_not_reflected_in_ast = 5000;
        x64_options = {false, false, true};
        llvm_options = {
            function_sections = false;
            enable_tail_calls = false;
            enable_loop_unrolling = false;
            enable_slp_vectorization = false;
            enable_loop_vectorization = false;
            reroll_loops = false;
            verify_input = false;
            verify_output = false;
            merge_functions = false;
            disable_inlining = true;
            disable_mem2reg = false;
            enable_split_modules = true;
            output_bitcode_before_optimizations = false;
            output_llvm_ir_before_optimizations = false;
            output_bitcode = false;
            output_llvm_ir = false;
            target_system_triple = "";
            target_system_cpu = "";
            target_system_features = "";
            code_gen_optimization_level = 0;
            code_gen_size_level = 0;
        };
    };
    output_executable_name = "my_program";
    output_path = "";
    intermediate_path = ".build/";
    entry_point_name = "";
    compile_time_command_line = ["30.4_build_options.jai"];
    temporary_storage_size = 32768;
    import_path = ["c:/jai/modules/"];
    additional_linker_arguments = [];
    user_data_u64 = 0;
    user_data_string = "";
    user_data_pointer = null;
    user_data_pointer_size = 0;
}
*/