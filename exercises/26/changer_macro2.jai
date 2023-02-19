#import "Basic";

changer :: (times: int, plus: int) #expand {
    `x *= times;
    `x += plus;
}

main :: () {
    x := 5;
    print("To begin with, x is %.\n", x);

    changer(3, 2);
    print("Now x is %.\n", x);

    changer(-1, 10);
    print("Now x is %.\n", x);
}
