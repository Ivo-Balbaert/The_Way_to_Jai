#import "Basic";
 
Stock :: struct {
    x : int;
}
 
st : Stock;
st_data :: #run store_as_u8(make_struct());   // (1) 
 
make_struct :: () -> Stock {
    // compute a struct
    return Stock.{12};
}

store_as_u8 :: (value : $T) -> [] u8 {
    array : [size_of(T)] u8;
    memcpy(*array, *value, size_of(T));
    return array;
}
 
restore_from_u8 :: (dest: *$T, data: [] u8) {
    value : T;
    memcpy(dest, data.data, size_of(T));
}
 
init :: () {
    restore_from_u8(*st, st_data);
}
 
main :: () {
    print("% % % - % % \n", st, st.x, type_of(st), st_data, type_of(st_data)); 
    // (2) => {0} 0 Stock - [12, 0, 0, 0, 0, 0, 0, 0] [8] u8
    init();  // (3) 
    print("% % %\n", st, st.x, type_of(st)); // => {12} 12 Stock
}

