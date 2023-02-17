#import "Basic";

bit_reverse64  :: (x: u64) -> u64 #expand {
  rdi: u64 = x;
  rax, rcx, rdx: u64;
  #asm {
    bswap.q   rdi;
    mov.q     rax, 1085102592571150095;
    and.q     rax, rdi;
    shl.q     rax, 4;
    mov.q     rcx, -1085102592571150096;
    and.q     rcx, rdi;
    shr.q     rcx, 4;
    or.q      rcx, rax;
    mov.q     rax, 3689348814741910323;
    and.q     rax, rcx;
    mov.q     rdx, -3689348814741910324;
    and.q     rdx, rcx;
    shr.q     rdx, 2;
    lea.q     rax, [rdx + rax*4];
    mov.q     rcx, 6148914691236517205;
    and.q     rcx, rax;
    mov.q     rdx, -6148914691236517206;
    and.q     rdx, rax;
    shr.q     rdx;
    lea.q     rax, [rdx + rcx*2];
  }
  return rax;
}

main :: () {
    x := cast(u64) 0xA;
    y := bit_reverse64(x);
    print("%\n", y); // => 5764607523034234880
    // Binary convert this numnber:
    // 0101000000000000000000000000000000000000000000000000000000000000
}