#import "Basic";
#import "File";
#import "Input";
#import "Random";
#import "Simp";
#import "Sound_Player";
#import "Wav_File";
#import "Window_Creation";

OGG :: "ogg";
WAV :: "wav";
sound_alien_dies:          *Mixer_Sound_Data;
sound_player :             *Sound_Player;
last_time    : float64;

load_sound :: (basename: string) -> *Mixer_Sound_Data {
    name := tprint("assets/sounds/%", basename);
    data := load_audio_file(name);

    if !data {
        print("Error: Could not load sound file: %\n", name);
        exit(1);
    }

    return data;
}

load_audio_file :: (name : string) -> *Mixer_Sound_Data {
    data : *Mixer_Sound_Data = null;

    file_data, success := read_entire_file(name);
    if !success return data;

    has_extension :: (name: string, extension: string) -> bool {
        if name.count < extension.count  return false;
        test := name;
        advance(*test, name.count - extension.count);
        return test == extension;
    }

    if has_extension(name, WAV) {
        data = New(Mixer_Sound_Data);
        data.name = copy_string(name);
        data.buffer = file_data;

        format, samples, success2, extra := get_wav_header(data.buffer);
        if !success2 {
            log_error("Unable to parse '%' as wav.\n", data.full_path);
            return data;
        }

        if format.wFormatTag == WAVE_FORMAT_PCM {
            data.type                     = .LINEAR_SAMPLE_ARRAY;
            data.nchannels                = cast(u16) format.nChannels;
            data.nsamples_times_nchannels = samples.count/2;
        } else if format.wFormatTag == WAVE_FORMAT_DVI_ADPCM {
            data.type             = .ADPCM_COMPRESSED;
            data.wSamplesPerBlock = extra.wSamplesPerBlock;
            data.nBlockAlign      = format.nBlockAlign;
            data.nchannels = cast(u16) format.nChannels;
            data.nsamples_times_nchannels = extra.wSamplesAccordingToFactChunk * data.nchannels;
        } else {
            assert(false);
        }

        data.samples       = cast(*s16) samples.data;
        data.sampling_rate = cast(u32) format.nSamplesPerSec;
    } else if has_extension(name, OGG) {
        data = New(Mixer_Sound_Data);
        data.name   = copy_string(name);
        data.buffer = file_data;
        data.type   = .OGG_COMPRESSED;
    } else { // Unsupported format. 
    }

    return data;
}

play_sound :: (data: *Mixer_Sound_Data, perturb: bool = true) -> *Sound_Stream {
    stream := make_stream(sound_player, data);

    if stream {
        stream.sound_data = data;
    }

    if perturb && stream {
        stream.user_volume_scale = random_get_within_range(0.7, 1);
        stream.desired_rate = random_get_within_range(0.7, 1.22);
    }

    stream.repeat_end_position = cast(int)(data.sampling_rate * 234.475);  // @Temporary @Hack! We do not get the duration by default from an ogg file...
    
    return stream;
}

main :: () {
    window := create_window(250, 250, "Sound");  

    sound_player = New(Sound_Player);    // (1)
    sound_player.update_history = true;
    // sound_alien_dies          = load_sound("alien_dies.wav");  // (2A)
    sound_alien_dies       = load_sound("lux_aeterna.ogg"); // (2B)     

    stream := play_sound(sound_alien_dies, false);  // (3)
    if stream {
        stream.flags |= .REPEATING;
        stream.repeat_end_position = cast(int)(sound_alien_dies.sampling_rate * 234.475);  // @Temporary @Hack! We do not get the duration by default from an ogg file...
        stream.category = .MUSIC;
    }

    success := init(sound_player, xx window, true, true);
    assert(success);    

    while true {              // (4)             
        dt : float;
        now := get_time();
        if last_time == 0 { dt = 0; } 
        else { dt = cast(float)(now - last_time); }
        last_time = now;
 
        pre_entity_update(sound_player);
        for sound_player.streams  it.marked = true;
        post_entity_update(sound_player, dt);
    }
}