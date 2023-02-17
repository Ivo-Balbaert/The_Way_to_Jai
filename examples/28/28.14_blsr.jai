#import "Basic";

popbit :: (a: u64) -> u64 #expand {
  #asm { blsr.q a, a; }
  return a;
}

main :: () {
    a: u64 = 0xFF;
    print("%\n", formatInt(a, 2));
    a = popbit(a);
    print("%\n", formatInt(a, 2));
    a = popbit(a);
    print("%\n", formatInt(a, 2));
    a = popbit(a);
    print("%\n", formatInt(a, 2));
}

/*
11111111
11111110
11111100
11111000
*/