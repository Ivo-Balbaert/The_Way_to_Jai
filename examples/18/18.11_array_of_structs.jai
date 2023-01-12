#import "Basic";

Vec2 :: struct {
    x: float = 1;
    y: float = 4;
}

Subscription :: struct {
    subscriber: string;
    no_payments: u32;
}

main :: () {
    va: [10] Vec2;                      // (1)
    print("% %\n", va[7].x, va[7].y); // => 1 4
    // loop through array:
    for va print("% % - ", it.x, it.y);  // (2)
    // => 1 4 - 1 4 - 1 4 - 1 4 - 1 4 - 1 4 - 1 4 - 1 4 - 1 4 - 1 4 -
    print("\n"); 
    va2 : [10]Vec2 = ---;                // (3)
    print("% %\n", va2[7].x, va2[7].y);  // => 0 0 // undefined behavior prints mostly 0 0

    subscriptions: [..]Subscription;
    sub1 := array_add(*subscriptions);    // (4)
    sub1.subscriber = "John";
    sub1.no_payments = 15;
    sub2 := array_add(*subscriptions);    
    sub2.subscriber = "Vera";
    sub2.no_payments = 8;
    print("Subscriptions: %\n", subscriptions);
    // => Subscriptions: [{"John", 15}, {"Vera", 8}]
}