// The Broadcaster is a typical design pattern and allows to send Events 
// to it's subscribers by in turn calling their callbacks
#import "Basic";

Event :: struct {
    msg: string;
}

event :: (msg: string) -> *Event {
    res := New(Event);
    res.msg = msg;
    return res;
}

Broadcaster :: struct {
    subscriptions: [..]Subscription;
    
    Subscription :: struct {
        subscriber: *void;
        callback: (*void, *Event) -> ();
    }
}

subscribe :: (bus: Broadcaster, sub: *$T, callback: (*T, *Event)) {
    subscription := array_add(*bus.subscriptions);
    subscription.subscriber = sub;
    subscription.callback   = cast((*void, *Event)->())callback;
}

unsubscribe :: (bus: Broadcaster, sub: *$T) {
    for bus.subscriptions {
        if it.subscriber == sub {
            remove it;
        }
    }
}

broadcast :: (bus: Broadcaster, event: *Event, consume_event: bool = true) {
    for bus.subscriptions {
        it.callback(it.subscriber, event);
    }
    if consume_event then free(event);
}

Subscriber :: struct {}

subscr_hello :: (f: *Subscriber, e: *Event) {
    print("Hello from a Subscriber: \"%\"\n", e.msg);
}

main :: () {
    bus : Broadcaster;

    f := New(Subscriber);
    g := New(Subscriber);

    subscribe(bus, f, subscr_hello);
    subscribe(bus, g, subscr_hello);

    broadcast(bus, event("what's up?"));
    unsubscribe(bus, f);
    broadcast(bus, event("nothing"));
}

/*
Hello from a Subscriber: "what's up?"
Hello from a Subscriber: "what's up?"
Hello from a Subscriber: "nothing"
*/