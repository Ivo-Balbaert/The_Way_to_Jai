#import "Basic";

Person :: struct {
    name: string;
}

Patient :: struct {
    using pe: Person;      // (1)
    disease: string;   
}

main :: () {
    pat1 : Patient;        // (1B)
    // pat1.pe.name = "Johnson";
    pat1.name = "Johnson"; // (2)
    pat1.disease = "Bronchitis";
    print("Patient is: %\n", pat1); // => Patient is: {{"Johnson"}, "Bronchitis"}

    using pat1;            // (3)
    // using pat1: Patient;   
    print("Patient has name: %\n", name); // => Patient has name: Johnson
}

