#import "Basic";

Person :: struct {                      // (1)
  name: string;
  age: int;
  is_cool: bool;
}

SOA :: struct(T: Type, count: int) {    // (2)
  #insert -> string {                   // (3)
    builder: String_Builder;            // (4)
    defer free_buffers(*builder);
    t_info := type_info(T);             // (5)
    for fields: t_info.members {        // (6)
      print_to_builder(*builder, "  %1: [%2] type_of(T.%1);\n", fields.name, count);  // (7)
    }
    result := builder_to_string(*builder);  // (8)
    return result;
  }
}

main :: () {
  soa_person: SOA(Person, 5);       // (9)
  print("soa_person is: %\n", soa_person);
  for i: 0..soa_person.count-1 {    // (10)
    print("Person[%]: name= %, age= %, is_cool= %\n", i, soa_person.name[i], soa_person.age[i], soa_person.is_cool[i]);
  } // => see in /* */ after program
  print("soa_person is: %\n", soa_person);
  // => soa_person is: {["", "", "", "", ""], [0, 0, 0, 0, 0], [false, false, false, false, false]}

  // an aos example:
  // if you do: arrp := Person.[p1, p2, p3, p4, p5] , with for example: p1 := Person.{"Ivo", 66, true};
  // => Error: Attempt to use a non-literal element inside an array literal! (At index 4.)
  arrp := Person.[Person.{"Ivo", 66, true}, Person.{"Dolf", 42, false}, Person.{"Laura", 28, true}, 
                Person.{"Gabriel", 30, true}, Person.{"Denise", 63, false}];   // (11)
  // how to transform aos to soa: arrp --> soa_person
  for arrp {       // (12)
    soa_person.name[it_index] = it.name;
    soa_person.age[it_index] = it.age;
    soa_person.is_cool[it_index] = it.is_cool;
  }
  print("soa_person is: %", soa_person);  
  // => soa_person is: {["Ivo", "Dolf", "Laura", "Gabriel", "Denise"], [66, 42, 28, 30, 63], 
  //                    [true, false, true, true, false]}
}

/*
Person[0]: name= , age= 0, is_cool= false
Person[1]: name= , age= 0, is_cool= false
Person[2]: name= , age= 0, is_cool= false
Person[3]: name= , age= 0, is_cool= false
Person[4]: name= , age= 0, is_cool= false
*/