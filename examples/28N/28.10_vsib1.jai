#import "Basic";

main :: () {
    orig_arr := float.[ 1, 2, 3, 4, 5, 6, 7, 8 ];
    gather_indices := u32.[ 0, 6, 5, 2, 3, 4, 1, 7 ];
    dest_arr: [8] float;

    orig_arr_ptr := orig_arr.data;
    gather_indices_ptr := gather_indices.data;
    dest_arr_ptr := dest_arr.data;

    #asm AVX, AVX2 {
        movdqu vindex:, [gather_indices_ptr];       // (1) 
        pcmpeqd gather_mask:, gather_mask, gather_mask; // (2)
        gatherdps gather_dest:, [orig_arr_ptr + vindex*4], gather_mask;
        movdqu [dest_arr_ptr], gather_dest;         // (3)
    }

    print("gather result: %\n", dest_arr);          // (4)
    // => gather result: [1, 7, 6, 3, 4, 5, 2, 8] 
}