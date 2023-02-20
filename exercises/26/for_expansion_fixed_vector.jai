#import "Basic";

FixedVector :: struct($T: Type, N: int) {
  values : [N]T;
  count : int;
}

// Push a value!
push :: (vec: *FixedVector, value: $T) {
  if vec.count < vec.N {
    vec.values[vec.count] = value;
    vec.count += 1;
  }
}

// iterate all values
for_expansion :: (vec: FixedVector, body: Code, flags: For_Flags) #expand {
  // Loop over inner array by count
  for i : 0..vec.count - 1 {
    // Must declare `it and `it_index
    `it := vec.values[i];
    `it_index := i;

    // insert user code
    #insert body;
  }
}

// declare a custom iterator
skip_fives :: (vec: FixedVector, body: Code, flags: For_Flags) #expand {
  // perform normal iteration
  for value, index : vec {
    // we don't like 5, booo!
    if value == 5 continue;
    
    // declare required `it and `it_index
    `it := value;
    `it_index := index;
  
    // insert user code
    #insert body;
  }
}
main :: () {
    // Declare a vector and push some values
    myVec : FixedVector(int, 10);
    push(*myVec, 5);
    push(*myVec, 1);
    push(*myVec, 5);
    push(*myVec, 2);
    push(*myVec, 5);
    push(*myVec, 3);

    // Loop and print
    for value : myVec print("% ", value);
    // => 5 1 5 2 5 3 
    
    print("\n");
    // iterate using skip_fives
    for :skip_fives v: myVec {
        print("% ", v);
    }
    // => 1 2 3
}