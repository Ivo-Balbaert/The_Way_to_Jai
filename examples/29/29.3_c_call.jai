#import "Basic";

IL_LoggingLevel :: u16;
IL_Logger_Callback :: #type(level: IL_LoggingLevel, text: *u8, ctx: *void) -> void #c_call; // (1)

logger_callback :: (level: IL_LoggingLevel, text: *u8, ctx: *void) #c_call {  // (2)
    new_context : Context;
    // print("I am in logger callback");
    // => Error: Cannot call into a native procedure, 
    // from a #c_call procedure, without using push_context.
    push_context new_context {
        log("%", to_string(text));
        print("I am in logger callback");
    }
}

main :: () {
    logger_callback(4, "You have been logged!", null);
    // => I am in logger callback
    // => You have been logged!
}