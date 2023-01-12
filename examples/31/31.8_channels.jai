#import "Basic";

Channel :: struct(T: Type, n: u64) {
    buffer      : [n]T;
    writeidx    : u64 = 0;
    readidx     : u64 = 0;
    unread      : u64 = 0;
}

channel_reset :: (c: *Channel($T, $n)) {
    c.unread = 0;
}

channel_write :: (using c: *Channel($T, $n), data: T) {
    while unread == buffer.count sleep_milliseconds(50);

    buffer[writeidx] = data;
    writeidx = (writeidx + 1) % buffer.count;
    unread += 1;
}

channel_read :: (using c: *Channel($T, $n)) -> T {
    while unread == 0 sleep_milliseconds(50);

    val := buffer[readidx];
    readidx = (readidx + 1) % buffer.count;
    unread -= 1;
    return val;
}

channel_write_array :: (c: *Channel($T, $n), data: []T) {
    // Note: This will block if the channel buffer is full.
    for data channel_write(c, it);
}

channel_read_all :: (c: *Channel($T, $n)) -> [..]T {
    // Note: This will read everything there is currently in the channel.
    out : [..]T;

    while c.unread > 0 array_add(*out, channel_read(c));
    return out;
}

main :: () {
    d : Channel(int, 20);
    print("channel d has buffer of %\n", d.buffer.count);

    channel_write(*d, 1);
    print("Read from d: %\n", channel_read(*d));
    channel_write(*d, 2);
    print("Read from d: %\n", channel_read(*d));
    channel_write(*d, 3);
    channel_write(*d, 4);
    print("Read from d: %\n", channel_read(*d));
    channel_write(*d, 5);
    print("Read from d: %\n", channel_read_all(*d));

    channel_write_array(*d, int.[10, 20, 30]);
    print("Read from d: %\n", channel_read(*d));
    channel_reset(*d);
    print("Read from d: %\n", channel_read_all(*d));
}

/*
channel d has buffer of 20
Read from d: 1
Read from d: 2
Read from d: 3
Read from d: [4, 5]
Read from d: 10
Read from d: []
*/