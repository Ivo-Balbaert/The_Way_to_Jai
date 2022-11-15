add_regs :: (c: __reg, d: __reg) #expand {  // (1)
  #asm {
     add c, d;
  }
}

main :: () {
  #asm {            // (2)
     mov a:, 10;
     mov b:, 7;
  }

  add_regs(b, a);   // (3)
}