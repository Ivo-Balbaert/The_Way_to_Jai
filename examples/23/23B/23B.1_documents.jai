#import "Basic";

Document :: struct {      // (1)
    type:     Type;       
    filename: string;    
}

Video_File :: struct {    // (2)
    using #as base: Document;  // (3)
    
    duration:           float;
    width, height:      int;
    frames_per_second:  u16;
    number_of_channels: u8;
}

Audio_File :: struct {      // (4)
    using #as base: Document;  
    
    duration:      float;
    sampling_rate: u32;
}

Executable_File :: struct {     // (5)
        using #as base: Document;

        base.type = Executable_File;  // (5B)
        is_a_rootkit := false;
}

report :: (d: Document) {       // (6)
    print("Document type %, filename '%'.\n", d.type, d.filename);
}

full_report :: (doc: *Document) {  // (7)
    if doc.type == {
        case Video_File;
        vid := cast(*Video_File) doc;
        print("'%' is a video, % seconds long. Its resolution is %x%, % channels, and it runs at % frames per second.\n",
                vid.filename, vid.duration, vid.width, vid.height, vid.number_of_channels, vid.frames_per_second);
        case Audio_File;
        aud := cast(*Audio_File) doc;
        print("'%' is an audio, % seconds long, sampled at % Hz.\n", 
                aud.filename, aud.duration, aud.sampling_rate);
        case;
        print("Error: Document of invalid type!\n");
    }
}

make_document :: ($T: Type, name: string) -> T {  // (8) 
    doc: T;
    doc.type     = T;
    doc.filename = name;
    return doc;
}

heap_document :: ($T: Type, name: string) -> *T { //  (11) 
    doc: *T = alloc(size_of(T));  
    doc.type     = T;
    doc.filename = name;
    return doc;
}

main :: () {
    v: Video_File;
    v.type              = Video_File;
    v.filename          = "im_on_a_boat.fmv";
    v.frames_per_second = 30;
    
    a: Audio_File;
    a.type          = Audio_File;
    a.filename      = "i_threw_it_on_the_ground.wav";
    a.sampling_rate = 44100;

    report(v); // => Document type Video_File, filename 'im_on_a_boat.fmv'.
    report(a); // => Document type Audio_File, filename 'i_threw_it_on_the_ground.wav'.

    vid := make_document(Video_File, "always_be_closing.mp4");        // (9)
    aud := make_document(Audio_File, "apple_pie_from_scratch.wav");   // (10)

    report(vid); // => Document type Video_File, filename 'always_be_closing.mp4'.
    report(aud); // => Document type Audio_File, filename 'apple_pie_from_scratch.wav'.

    heap_vid := heap_document(Video_File, "blow_up_the_moon.mp4"); //  (12)
    heap_aud := heap_document(Audio_File, "some_summers_they_drop_like_flys.wav");

    defer free(heap_vid);   // (13)
    defer free(heap_aud);

    report(<< heap_vid); // (14) => Document type Video_File, filename 'blow_up_the_moon.mp4'.
    report(<< heap_aud); // => Document type Audio_File, filename 'some_summers_they_drop_like_flys.wav'.

    heap_vid.width  = 800;
    heap_vid.height = 600;
    heap_vid.number_of_channels = 4;
    heap_vid.duration = 133.3;
    heap_vid.frames_per_second = 30;
    full_report(heap_vid);
    // => 'blow_up_the_moon.mp4' is a video, 133.300003 seconds long. 
    // Its resolution is 800x600, 4 channels, and it runs at 30 frames per second.

    heap_aud.duration = 192.5;
    heap_aud.sampling_rate = 44100;
    full_report(heap_aud);
    // => 'some_summers_they_drop_like_flys.wav' is an audio, 192.5 seconds long, 
    // sampled at 44100 Hz.

    exe: Executable_File;
    exe.is_a_rootkit = true;
    report(exe); 
    // => Document type Executable_File, filename ''.
}