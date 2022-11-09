#import "Basic";

add :: (x: int, y: int) -> int {
    return x + y;
}

main :: () {
    info_procedure := cast(*Type_Info_Procedure) type_info(type_of(add)); // (1)
    print("% (", info_procedure.info.type); // => PROCEDURE  // (2)
    for info_procedure.argument_types { // (3)
        print("% - ", << it); 
        if it_index != info_procedure.argument_types.count-1 then print(", ");
    }
    print(") -> ");
    for info_procedure.return_types { // (4)
        print("% - ", << it); 
        if it_index != info_procedure.return_types.count-1 then print(", ");
    }
}

// => PROCEDURE ({INTEGER, 8} - , {INTEGER, 8} - ) -> {INTEGER, 8} - 


