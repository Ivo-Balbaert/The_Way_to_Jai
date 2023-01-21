#import "Basic";
#import "Compiler";
#import "File";
#import "String";

main :: () {
    data1 :: #run add_global_data(                  // (1)
        xx join(
            "GIF89a\x01\x00\x01\x00\x80\x01\x00\xff\xff\xff\x00",
            "\x00\x00!\xf9\x04\x01\n\x00\x01\x00,\x00\x00\x00",
            "\x00\x01\x00\x01\x00\x00\x02\x02L\x01\x00;",
        ),
        .READ_ONLY,
    );
    print("%\n", data1.count); // => 43
    
    data2 :: #run add_global_data(xx read_entire_file("pixel.png"), .READ_ONLY); // (2)
    print("%\n", data2.count); // => 43
}