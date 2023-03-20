#import "Basic";
#import "Compiler";

build :: ()
{
    // Build the dll
    {
        w := compiler_create_workspace();
        options := get_build_options(w);
        options.output_type = .DYNAMIC_LIBRARY;   // (1)
        options.output_executable_name = "dynlib";
        set_build_options(options, w);

        compiler_begin_intercept(w);
        add_build_file("dynlib.jai", w);
        while true {                // is needed!
             message := compiler_wait_for_message();
             if !message break;
             if message.kind == .COMPLETE {
                mc := cast(*Message_Complete) message;
                if mc.error_code != .NONE {
                    print("DLL compilation failed; exiting without compiling the main program.\n");
                    return;
                }
                break;
            }
        }
        compiler_end_intercept(w);
    }

    // Build the exe after 
    {
        w := compiler_create_workspace();
        options := get_build_options(w);
        options.output_executable_name = "main7";
        set_build_options(options, w);
        add_build_file("main7.jai", w);
    }

    set_build_options_dc(.{do_output=false});
}

#run build();