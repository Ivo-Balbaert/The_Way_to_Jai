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

  target_options.array_bounds_check = .OFF;
  target_options.cast_bounds_check  = .OFF; 
  target_options.null_pointer_check = .OFF; 
  
  target_options.runtime_storageless_type_info = true;

  set_build_options(target_options, w);
  set_build_file_path("./");  // output executable in current folder (= default)
  
  add_build_file("main.jai", w);
}

main :: () {}

#run build();