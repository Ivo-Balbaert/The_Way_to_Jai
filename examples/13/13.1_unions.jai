#import "Basic";

T :: union {                // (1)
  a: u16 = 0; 
  b: float64 = 5.0; 
  c: Type; 
}

// equivalent:
Ts :: struct {              // (2)
  a: u16; 
  #place a;
  b: float64;
  #place a;
  c: Type;
}

// void as a union member // (2B)
Object :: struct {
  member: void; 
  #place member;
  x: float;
  #place member;
  y: float;
  #place member;
  z: float;
}

main :: () {
  t: T;             // (3)
  t.a = 100;        // (4)
  print("t.a = %\n", t.a); // prints out 100
  t.b = 3.0;        // (5)
  print("t.b = %\n", t.b); // prints out 3.0
  print("t.a = %\n", t.a); // (6) prints out gibberish, since b has been assigned
  t.c = s64;
  print("t.c = %\n", t.c); // prints out s64
  print("t.a = %\n", t.a); // same as (6)
  print("The size of the union T is %\n", size_of(T)); // 8
}

/*
t.a = 100
t.b = 3
t.a = 4613937818241073152
t.c = s64
t.a = 140701717295104
The size of the union T is 8
*/