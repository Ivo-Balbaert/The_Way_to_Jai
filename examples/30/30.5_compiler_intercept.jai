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
//        print(" >> %\n", <<message); // (4) => see output below
        if !message break; 
        if message.kind == {
            case .COMPLETE;          // (5)
                print(" >> %\n", <<message);
                break;
            case .FILE; {            
                message_file := cast(*Message_File) message;    // (6)
//                print("Loading file '%'.\n", message_file.fully_pathed_filename); // (7)
            }
            case .IMPORT; {            
                message_import := cast(*Message_Import) message;          // (8)
//              print("Import module '%'\n", message_import.module_name); // (9)
            }
            case .PHASE; {            
                message_phase := cast(*Message_Phase) message;     // (10)
//              print("Entering phase %\n", message_phase.phase);  // (11)
                if message_phase.phase == .TYPECHECKED_ALL_WE_CAN  {  // (11B)
                    print("Typechecking done - stop compilation");
                    exit(0);
                }
            }
            case .TYPECHECKED; {            
                message_typechecked := cast(*Message_Typechecked) message; // (12)
                for message_typechecked.declarations {  // (13)
//                    print("Code declaration: %\n", it);
               }
            }
            case .DEBUG_DUMP; {            
                dump_message := cast(*Message_Debug_Dump) message;   // (14)
                print("Here is the dump text: %\n", dump_message.dump_text); // (15)
            }
            case .ERROR; {            
                // handle error
            }
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