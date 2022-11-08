#import "Basic";

IL_LoggingLevel :: u16;
IL_Logger_Callback :: #type(level: IL_LoggingLevel, text: *u8, ctx: *void) -> void #c_call; // (1)

logger_callback :: (level: IL_LoggingLevel, text: *u8, ctx: *void) #c_call {  // (2)
    new_context : Context;
    push_context new_context {
        log("%", to_string(text));
    }
}

main :: () {
    logger_callback(4, "You have been logged!", null);
    // => You have been logged!
}