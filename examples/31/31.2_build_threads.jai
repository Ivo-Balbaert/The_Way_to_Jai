#import "Basic";
#import "Compiler";
#import "Process";

#load "build_gui.jai";      // (1)

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

    show_gui();             // (2)           

    compiler_begin_intercept(w);     
    add_build_file("main.jai", w);   
    
    while true {                     
        message := compiler_wait_for_message();  

        sleep_milliseconds(10);  // (3)  
        
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

    wait_gui();     // (4)  

    if success {            
        print("[SUCCESS!]\n");
        run_command(target_options.output_executable_name);  
    }    
}

main :: () {}

#run build();