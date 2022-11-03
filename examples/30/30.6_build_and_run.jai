#import "Basic";
#import "Compiler";
#import "Process";

success := false;

build :: () {
    w := compiler_create_workspace();                     
    if !w {
        print("Workspace creation failed.\n");
        return;
    }

    target_options := get_build_options(w);               
    target_options.output_executable_name = "brun";    
    set_build_options(target_options, w);                 

    compiler_begin_intercept(w);     
    add_build_file("main2.jai", w);   
    
    while true {                     
        message := compiler_wait_for_message();  
        if !message break; 
        if message.kind == {
            case .COMPLETE;          // (1)
                print(" >> %\n", <<message);
                message_complete := cast(*Message_Complete) message;  // (2)
                success = message_complete.error_code == 0;           // (3)
                break;
        }
    }
    compiler_end_intercept(w);   

    if success {            
        print("[SUCCESS!]\n");
        run_command(target_options.output_executable_name);  // (4)
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