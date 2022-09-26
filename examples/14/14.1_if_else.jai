#import "Basic";

main :: () {
    dead := false;
    health := 48;

    if dead {       // (1)
        print("Game over!");
        exit;
    }
    
    if dead {       // (2)
        print("Game over!");
        exit;
    } else {  // we are still alive!
        print("You still have a chance to win!\n");
    }

    a1 := 7;
    b1 := 8;
    if a1 == b1  // (3)
        print("They're equal!\n"); 
    else
        print("They're not equal!\n");
    // if a1 = b1  // (3B) // Error: Operator '=' can only be used at statement level.
    //    print("They're equal!\n"); 

    b1 = 7;
    if a1 == b1 print("They're equal!\n");    // (4)
    if (a1 == b1) print("They're equal!\n");  
    if dead then exit;                        // (5)
    
    if health >= 50 {                         // (6)
        print("Continue to fight!");
    } else if health >= 20 {
        print("Stop the battle and regain health!\n");
    } else {
        print("Hide and try to recover!");
    }

    grade := 100;                           // (7)
    if grade >= 97 {
        print("Your grade is an A+\n");
    } else if grade >= 90 {
        print("Your grade is an A\n");
    } else if grade >= 80 {
        print("Your grade is a B\n");
    } else if grade >= 70 {
        print("Your grade is a C\n");
    } else if grade >= 60 {
        print("Your grade is a D\n");
    } else {
        print("You grade is a F\n");
    }
}

/*
You still have a chance to win!
They're not equal!
They're equal!
Stop the battle and regain health!
Your grade is an A+
*/