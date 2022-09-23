#import "Basic";

Node :: struct {           
    value: int;
}

Super_Node :: struct {      
    node_a: Node;
    node_b: Node;
}

main :: () {
    // Long version: full
    n1 : Node;
    n1.value = 42;
    n2 : Node;
    n2.value = 108;
    sn : Super_Node;
    sn.node_a = n1;
    sn.node_b = n2;
    print("%\n", sn); // => {{42}, {108}}

    // Short version:
    sns := Super_Node.{Node.{42}, Node.{108}};
    print("%\n", sns); // => {{42}, {108}}
}
