#import "Basic";

Person :: struct {
    name: string;
}

Patient :: struct {     // (1)
    using as: Person;
    disease: string;   
}

Employee :: struct {    // (2)
    using #as p: Person;
    profession: string;
}

// Example 2:
Number :: struct {      // (5)
  #as i: int;
  f: float = 3.14;
}

function :: (i: int) {
  print("i is %\n", i);
}

main :: () {
    pat1 : Patient;  
    pat1.name = "Johnson"; 
   
    emp1: Employee;
    emp1.name = "Gates";
    emp1.profession = "software engineer";
    print("%\n", emp1); // => {{"Gates"}, "software engineer"}

    p1: Person;
    // p1 = pat1; // (3) Error: Type mismatch: incompatible structs (wanted 'Person', given 'Patient').
    p1 = emp1;
    print("%\n", p1); // (4) => {"Gates"}

    // Example 2:
    num := Number.{42, 3.1415};
    print("num is %\n", num); // => num is {42, 3.1415}
    function(num); // (6) => a is 42
}



