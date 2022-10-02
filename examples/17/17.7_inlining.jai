test_local :: (x: int) { /*... */}
test_local_inline :: inline (x:int) { /*...*/ }

main :: () {
  test_local(1);        // (1) test_local called as function
  inline test_local(1); // (2) code of test_local is inlined

  test_local_inline(2); // (3) code of test_local_inline is inlined
  no_inline test_local_inline(2); // (4) not inlined
}

