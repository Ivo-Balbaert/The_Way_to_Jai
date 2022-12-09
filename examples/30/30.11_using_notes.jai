#import "Compiler";
#import "String";
#import "Basic";
#import "Sort";

#run {
  w := compiler_create_workspace();

  options := get_build_options(w);
  options.output_executable_name = "notes";
  set_build_options(options, w);

  compiler_begin_intercept(w);
  add_build_file("main4.jai", w);  

  procs: [..] string;                           // (1)
  gen_code := false;
  while true {
    message := compiler_wait_for_message();
    if !message break;
    if message.kind == {
    case .TYPECHECKED;
      typechecked := cast(*Message_Typechecked) message;
      for decl: typechecked.declarations {
        if equal(decl.expression.name , "main") {
          continue;
        }
        for note: decl.expression.notes {       // (2)
          if equal(note.text, "fruit") {
            array_add(*procs, copy_string(decl.expression.name));
          }
        }
    }
    case .PHASE;                                // (3)
      phase := cast(*Message_Phase) message;
      if gen_code == false && phase.phase == .TYPECHECKED_ALL_WE_CAN {
        code := generate_code();                // (4)
        add_build_string(code, w);              // (5)
        gen_code = true;
    }
    case .COMPLETE;
      break;
    }
  }
  compiler_end_intercept(w);
  set_build_options_dc(.{do_output=false});

  generate_code :: () -> string #expand {       // (6)
    bubble_sort(procs, compare);                // (7)
    builder: String_Builder;
    append(*builder, "main :: () {\n");
    for proc: procs {
      print_to_builder(*builder, "  %1();\n", proc);
    }
    append(*builder, "}\n");
    return builder_to_string(*builder);
  }
}