// An example that uses several different allocators, then asks them all
// who owns which memory.
//
// Note that this is probably not the kind of thing you want to do at runtime
// in the steady state, as it may not be very fast, but it could be a very helpful
// debugging facility.
//

#import "Basic";
#import "Pool";
#import "Flat_Pool";
#import "rpmalloc";

main :: () {
    pool: Pool;
    flat: Flat_Pool;

    a := context.default_allocator;
    b := Allocator.{pool_allocator_proc, *pool};
    c := Allocator.{flat_pool_allocator_proc, *flat};
    d := Allocator.{rpmalloc_allocator_proc, null};

    // rpmalloc needs explicit init right now, but others don't.
    d.proc(.STARTUP, 0, 0, null, null);  
    
    ma := alloc(1000, allocator=a);
    mb := alloc(1000, allocator=b);
    mc := alloc(1000, allocator=c);
    md := alloc(1000, allocator=d);

    report_who_owns(ma, a, b, c, d);
    report_who_owns(mb, a, b, c, d);
    report_who_owns(mc, a, b, c, d);
    report_who_owns(md, a, b, c, d);
}

report_who_owns :: (memory: *void, allocators: .. Allocator) {
    someone_owns_this := false;
    
    print("Querying all allocators for address: %\n", memory);
    
    for allocators {
        caps, name := get_capabilities(it);
        assert((caps & .IS_THIS_YOURS) != 0);  
        
        yours := cast(bool) it.proc(.IS_THIS_YOURS, 0, 0, memory, it.data);
        print("[%] says \"%\"\n", yours, name);

        someone_owns_this ||= yours;
    }

    assert(someone_owns_this);
}

/*
Querying all allocators for address: 217_186a_0080
[true] says "stripped-down rpmalloc 1.4.4 intended as Default_Allocator"
[false] says "modules/Pool"
[false] says "modules/Flat_Pool"
[false] says "rpmalloc 1.4.4"
Querying all allocators for address: 217_186b_0088
[true] says "stripped-down rpmalloc 1.4.4 intended as Default_Allocator"
[true] says "modules/Pool"
[false] says "modules/Flat_Pool"
[false] says "rpmalloc 1.4.4"
Querying all allocators for address: 217_18aa_0000
[false] says "stripped-down rpmalloc 1.4.4 intended as Default_Allocator"
[false] says "modules/Pool"
[true] says "modules/Flat_Pool"
[false] says "rpmalloc 1.4.4"
Querying all allocators for address: 217_28aa_0080
[false] says "stripped-down rpmalloc 1.4.4 intended as Default_Allocator"
[false] says "modules/Pool"
[false] says "modules/Flat_Pool"
[true] says "rpmalloc 1.4.4"
*/
