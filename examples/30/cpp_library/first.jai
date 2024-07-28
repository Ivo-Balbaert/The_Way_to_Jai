// This is just a small example of compiling a C++ library, generating bindings for it and using them.
// Look at modules/ImGui/generate.jai or modules/d3d11/generate.jai
// for more comprehensive examples of how to use the bindings generator.

#run build();

build :: () {
    set_build_options_dc(.{do_output=false});

	options := get_build_options();
    set_optimization(*options, Optimization_Type.DEBUG, true);
    success := build_cpp_dynamic_lib("cpp_library", "cpp_library.cpp", debug=true);
    if !success {
        compiler_set_workspace_status(.FAILED);
        return;
    }

    if !generate_bindings() {
        compiler_set_workspace_status(.FAILED);
        return;
    }

    w := compiler_create_workspace("Main program");
    
    options.output_type     = .EXECUTABLE;
    options.output_executable_name = "example";
    set_build_options(options, w);
    
    compiler_begin_intercept(w);
    add_build_file("main.jai", w);

    while true {
        message := compiler_wait_for_message();
        if message.kind == {
          case .TYPECHECKED;
            do_error_checking(null, message);
            
          case .COMPLETE;
            break;
        }
    }

    compiler_end_intercept(w);
}

generate_bindings :: () -> bool {
    output_filename: string;
    opts: Generate_Bindings_Options;
    {
        using opts;

        #if OS == .WINDOWS {
            output_filename          = "windows.jai";
            strip_flags = 0;
        } else #if OS == .LINUX {
            output_filename          = "linux.jai";
            strip_flags = .INLINED_FUNCTIONS; // Inlined constructor doesn't exist in the library
        } else #if OS == .MACOS {
            // @ToDo: Determine dynamically? Customize?
            array_add(*system_include_paths, "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include");
            output_filename          = "macos.jai";
            strip_flags = .INLINED_FUNCTIONS; // Inlined constructor doesn't exist in the library
        } else {
            assert(false);
        }

        array_add(*libpaths,       ".");
        array_add(*libnames,      "cpp_library");
        array_add(*system_include_paths, GENERATOR_DEFAULT_SYSTEM_INCLUDE_PATH);
        array_add(*source_files,  "cpp_library.h");
        array_add(*extra_clang_arguments, "-x", "c++", "-DWIN32_LEAN_AND_MEAN");

        // strip_flags &= ~(Strip_Flags.CONSTRUCTORS | .DESTRUCTORS);
    }

    return generate_bindings(opts, output_filename);
}

#scope_file

#import "Basic";
#import "Compiler";
#import "BuildCpp";
#import "Check";
#import "Bindings_Generator";
#import "File";
