#import "Basic";

Dragon :: struct {
    serial_no: int;
    name: string;
    strength: u8;
}

NR_DRAGONS :: 10;

main :: () {
    e1 := New(Dragon);
    e1.serial_no = 123;
    e1.name =  "Dragon1";
    e1.strength =  42;
    e2 := New(Dragon);
    e2.serial_no = 124;
    e2.name =  "Dragon2";
    e2.strength =  78;
    
    arr_dragons: [NR_DRAGONS] *Dragon; 
    defer { for arr_dragons  free(it); };
    arr_dragons[1] = e1;
    arr_dragons[2] = e2;
    arr_dragons[3] = New(Dragon);
    arr_dragons[3].serial_no = 666;
    print("the dragon array is: %\n", arr_dragons);
    // => the dragon array is: [null, 22a_1f40_4b20, 22a_1f40_4be0, 
    // 22a_1f40_4cd0, null, null, null, null, null, null]
}


