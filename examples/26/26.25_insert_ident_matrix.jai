#import "Basic";

Matrix :: struct (N: int) {
    items: [N*N] float;                  // (1)
    #insert #run set_diagonals_to_1(N);  // (2) 
}

set_diagonals_to_1 :: (N: int) -> string {
    builder: String_Builder;
    for 0..N-1 {
        print_to_builder(*builder, "items[%] = 1;\n", it*N + it);
    }
    return builder_to_string(*builder);
}

main :: () {
    m: Matrix(5);
    print("The matrix contains:\n");
    for j: 0..4 {
        for i: 0..4 {
            print("%  ", m.items[j*5 + i]);
        }
        print("\n");
    }
}

/*
The matrix contains:
1  0  0  0  0
0  1  0  0  0
0  0  1  0  0  
0  0  0  1  0
0  0  0  0  1
*/