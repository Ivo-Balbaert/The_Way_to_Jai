#import "Basic";

main :: () {
    a2 : [4][4] float;    // (1) - 2D static array
    print("a2 is: %\n", a2); // =>
//  a2 is: [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]
    b2 : [4][4][4] float; // 3D - static array
    print("b2 is: %\n", b2); // =>
// b2 is: [[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
//         [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]], 
//         [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]], 
//         [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]]  
    array3: [2][2] int = .[int.[1,0], int.[0,3]];
    print("array3 is: %\n", array3); // => array3 is: [[1, 0], [0, 3]]
    array4 := [2] int.[int.[1,0], int.[0,3]];

    luminance_color_ramp := ([3] float).[.[0,0,0],  // black
                                         .[0,0,1],  // blue
                                         .[0,1,1],  // cyan
                                         .[0,1,0],  // green
                                         .[1,1,0],  // yellow
                                         .[1,0,0],  // red
                                         .[1,0,1],  // magenta
                                         .[1,1,1]]; // white
    print("type_of(luminance_color_ramp) is %\n", type_of(luminance_color_ramp));
    // => type_of(luminance_color_ramp) is [8] [3] float32

    for luminance_color_ramp    print("% % % / ", it[0], it[1], it[2]); // (2)
    // => 0 0 0 / 0 0 1 / 0 1 1 / 0 1 0 / 1 1 0 / 1 0 0 / 1 0 1 / 1 1 1 /

// do they need to be freed, probably they are in stack ?
    array_free(a2);
    array_free(b2);
    array_free(array3);
    array_free(luminance_color_ramp);
}


