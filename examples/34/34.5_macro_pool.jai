#import "Basic";
#import "Pool";

use_pool :: (code: Code) #expand {
    pool: Pool;
    set_allocators(*pool);
    push_allocator(pool_allocator_proc, *pool);
    #insert code;
    release(*pool);
}

main :: () {
    x: string; // (1) 
    use_pool( #code {
        // your code here
        x = "some allocated data";
    } );
    print(x); // => some allocated data
}