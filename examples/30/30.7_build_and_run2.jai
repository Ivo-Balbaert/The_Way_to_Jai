#import "Basic";
#import "Compiler";
#import "Process";

success := false;           // compile is successful
run_on_success := false;    // compiler command line argument --run

build :: () {
    w := compiler_create_workspace();                     
    if !w {
        print("Workspace creation failed.\n");
        return;
    }

    target_options := get_build_options(w);               
    
    args := target_options.compile_time_command_line;  // (1)
    for args {                                         // (2)
        print ("% / ", it);
        if it == {
            case "run";
                run_on_success = true;
        }
    }
   
    target_options.output_executable_name = "brun";    
    set_build_options(target_options, w);                 

    compiler_begin_intercept(w);     
    add_build_file("main2.jai", w);   
    
    while true {                     
        message := compiler_wait_for_message();  
        if !message break; 
        if message.kind == {
            case .COMPLETE;         
                print(" >> %\n", <<message);
                message_complete := cast(*Message_Complete) message;  
                success = message_complete.error_code == 0;           
                break;
        }
    }
    compiler_end_intercept(w);   

    if success && run_on_success {         // (3)   
        print("[SUCCESS!]\n");
        run_command(target_options.output_executable_name);  
    }    
}

main :: () {}

#run build();

/*
...
>> {COMPLETE, 3}
[SUCCESS!]
This program was built with metaprogram 30.8_build_and_run.jai
...
*/