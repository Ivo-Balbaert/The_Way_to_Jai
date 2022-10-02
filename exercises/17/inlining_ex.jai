test_a :: () { /* ... */ }
test_b :: inline () { /* ... */ }
test_c :: no_inline () { /* ... */ }

main :: () {
    test_a(); // (1)
    test_b(); // (2) 
    test_c(); // (3)

    inline test_a(); // (4) 
    inline test_b(); // (5) 
    inline test_c(); // (6) 

    no_inline test_a(); // (7) 
    no_inline test_b(); // (8) 
    no_inline test_c(); // (9) 
}

/*
(1) Compiler decides whether to inline this
(2) Always inlined due to ":: inline" in definition
(3) Never inlined due to ":: no_inline" in definition
inline test_a()
(4) Always inlined
(5) Always inlined
(6) Always inlined
(7) Never inlined
(8) Never inlined
(9) Never inlined
*/
