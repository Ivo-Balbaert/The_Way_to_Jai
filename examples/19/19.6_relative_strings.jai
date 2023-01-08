#import "Basic";

Package :: struct {             
    strings: [3] string~s8;   // (1) 
    string_data: [100] u8;
}

S :: struct {
    str : string~s8;
    utf8 : [5]u8;
}

main :: ()  {
    s : S;                    // (2)
    s.utf8 = .[0xE3, 0x8B, 0xA1, 0, 0];
    write_relative_pointer(s8, *s.str.data, *s.utf8);
    s.str.count = 3;
    print("'%'\n", s.str);    // => '㋡'
}