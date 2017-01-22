#import "Superpowered.h"
#import "SuperpoweredAdvancedAudioPlayer.h"
#import "SuperpoweredSimple.h"
#import "SuperpoweredFX.h"
#import "SuperpoweredIOSAudioIO.h"
#import "SuperpoweredBandpassFilterbank.h"
#import "fftTest.h"
#import <mach/mach_time.h>
#import "SuperpoweredPerformance-Prefix.pch"
/*
 This is a .mm file, meaning it's Objective-C++. 
 You can perfectly mix it with Objective-C or Swift, until you keep the member variables and C++ related includes here.
 Yes, the header file (.h) isn't the only place for member variables.
 */
@implementation Superpowered {
    SuperpoweredAdvancedAudioPlayer *player;
    SuperpoweredFX *effects[NUMFXUNITS];
    SuperpoweredIOSAudioIO *output;
    float *stereoBuffer;
    bool started;
    uint64_t timeUnitsProcessed, maxTime;
    unsigned int lastPositionSeconds, lastSamplerate, samplesProcessed;
    pthread_mutex_t mutex;
    SuperpoweredBandpassFilterbank *filters;
    float bands[128][16];
    unsigned int samplerate, bandsWritePos, bandsReadPos, bandsPos, lastNumberOfSamples;

}

- (void)dealloc {
    delete player;
    for (int n = 2; n < NUMFXUNITS; n++) delete effects[n];
    free(stereoBuffer);
    delete filters;
    output = nil;
#if !__has_feature(objc_arc)
    [output release];
    [super dealloc];
#endif
}

// Called periodically by ViewController to update the user interface.
- (void)updatePlayerLabel:(UILabel *)label slider:(UISlider *)slider button:(UIButton *)button {
    bool tracking = slider.tracking;
    unsigned int positionSeconds = tracking ? int(float(player->durationSeconds) * slider.value) : player->positionSeconds;
    
    if (positionSeconds != lastPositionSeconds) {
        lastPositionSeconds = positionSeconds;
        NSString *str = [[NSString alloc] initWithFormat:@"%02d:%02d %02d:%02d", player->durationSeconds / 60, player->durationSeconds % 60, positionSeconds / 60, positionSeconds % 60];
        label.text = str;
#if !__has_feature(objc_arc)
        [str release];
#endif
    };

    if (!button.tracking && (button.selected != player->playing)) button.selected = player->playing;
    if (!tracking && (slider.value != player->positionPercent)) slider.value = player->positionPercent;
}

- (bool)toggleFx:(float)cadence {
    bool enabled = (player->tempo != 1.0f);
    player->setTempo(enabled ? 1.0f : (cadence/(player->bpm/60)), true);
    return !enabled;
}

- (void)togglePlayback { // Play/pause.
    player->togglePlayback();
}

- (void)seekTo:(float)percent {
    player->seek(percent);
}

- (void)toggle {
    if (started) [output stop]; else [output start];
    started = !started;
}

-(void)updateCadence:(double)cadence {
    player->setTempo(cadence/(player->bpm/60), true);
}

- (void)mapChannels:(multiOutputChannelMap *)outputMap inputMap:(multiInputChannelMap *)inputMap externalAudioDeviceName:(NSString *)externalAudioDeviceName outputsAndInputs:(NSString *)outputsAndInputs {}

// This is where the Superpowered magic happens.
static bool audioProcessing(void *clientdata, float **buffers, unsigned int inputChannels, unsigned int outputChannels, unsigned int numberOfSamples, unsigned int samplerate, uint64_t hostTime) {
    
    __unsafe_unretained Superpowered *self = (__bridge Superpowered *)clientdata;
    if (samplerate != self->samplerate) {
        self->samplerate = samplerate;
        self->filters->setSamplerate(samplerate);
    };
    
    // Mix the non-interleaved input to interleaved.
    float interleaved[numberOfSamples * 2 + 16];
    SuperpoweredInterleave(buffers[0], buffers[1], interleaved, numberOfSamples);
    
    // Get the next position to write.
    unsigned int writePos = self->bandsWritePos++ & 127;
    memset(&self->bands[writePos][0], 0, 16 * sizeof(float));
    
    // Detect frequency magnitudes.
    float peak, sum;
    self->filters->process(interleaved, &self->bands[writePos][0], &peak, &sum, numberOfSamples);
    
    // Update position.
    self->lastNumberOfSamples = numberOfSamples;
    __sync_synchronize();
    __sync_fetch_and_add(&self->bandsPos, 1);
    
    uint64_t startTime = mach_absolute_time();

    /*if (samplerate != self->lastSamplerate) { // Has samplerate changed?
        self->lastSamplerate = samplerate;
        self->player->setSamplerate(samplerate);
        for (int n = 2; n < NUMFXUNITS; n++) self->effects[n]->setSamplerate(samplerate);
    };*/
    
    // We're keeping our Superpowered time-based effects in sync with the player... with one line of code. Not bad, eh?
    //((SuperpoweredRoll *)self->effects[ROLLINDEX])->bpm = ((SuperpoweredFlanger *)self->effects[FLANGERINDEX])->bpm = ((SuperpoweredEcho *)self->effects[DELAYINDEX])->bpm = self->player->currentBpm;

 
     //Let's process some audio.
     //If you'd like to change connections or tap into something, no abstract connection handling and no callbacks required!
 
    bool silence = !self->player->process(self->stereoBuffer, false, numberOfSamples, 1.0f, 0.0f, -1.0);
    //if (self->effects[ROLLINDEX]->process(silence ? NULL : self->stereoBuffer, self->stereoBuffer, numberOfSamples)) silence = false;
    //self->effects[FILTERINDEX]->process(self->stereoBuffer, self->stereoBuffer, numberOfSamples);
    //self->effects[EQINDEX]->process(self->stereoBuffer, self->stereoBuffer, numberOfSamples);
    //self->effects[FLANGERINDEX]->process(self->stereoBuffer, self->stereoBuffer, numberOfSamples);
    //if (self->effects[DELAYINDEX]->process(silence ? NULL : self->stereoBuffer, self->stereoBuffer, numberOfSamples)) silence = false;
    //if (self->effects[REVERBINDEX]->process(silence ? NULL : self->stereoBuffer, self->stereoBuffer, numberOfSamples)) silence = false;

    // CPU measurement code to show some nice numbers for the business guys.
    uint64_t elapsedUnits = mach_absolute_time() - startTime;
    if (elapsedUnits > self->maxTime) self->maxTime = elapsedUnits;
    self->timeUnitsProcessed += elapsedUnits;
    self->samplesProcessed += numberOfSamples;
    if (self->samplesProcessed >= samplerate) {
        self->avgUnitsPerSecond = self->timeUnitsProcessed;
        self->maxUnitsPerSecond = (double(samplerate) / double(numberOfSamples)) * self->maxTime;
        self->samplesProcessed = self->timeUnitsProcessed = self->maxTime = 0;
    };

    self->playing = self->player->playing;
    if (!silence) SuperpoweredDeInterleave(self->stereoBuffer, buffers[0], buffers[1], numberOfSamples); // The stereoBuffer is ready now, let's put the finished audio into the requested buffers.
    return !silence;
}

- (id)init {
    self = [super init];
    if (!self) return nil;
    SuperpoweredFFTTest();

    started = false;
    lastPositionSeconds = lastSamplerate = samplesProcessed = timeUnitsProcessed = maxTime = avgUnitsPerSecond = maxUnitsPerSecond = 0;
    if (posix_memalign((void **)&stereoBuffer, 16, 4096 + 128) != 0) abort(); // Allocating memory, aligned to 16.

// Create the Superpowered units we'll use.
    player = new SuperpoweredAdvancedAudioPlayer(NULL, NULL, 44100, 0);
    player->open([[[NSBundle mainBundle] pathForResource:@"oroshi" ofType:@"mp3"] fileSystemRepresentation]);
    player->play(false);
    player->setBpm(140.0f);
    /*
    SuperpoweredFilter *filter = new SuperpoweredFilter(SuperpoweredFilter_Resonant_Lowpass, 44100);
    filter->setResonantParameters(1000.0f, 0.1f);
    effects[FILTERINDEX] = filter;
    
    effects[ROLLINDEX] = new SuperpoweredRoll(44100);
    effects[FLANGERINDEX] = new SuperpoweredFlanger(44100);
    
    SuperpoweredEcho *delay = new SuperpoweredEcho(44100);
    delay->setMix(0.8f);
    effects[DELAYINDEX] = delay;
    
    SuperpoweredReverb *reverb = new SuperpoweredReverb(44100);
    reverb->setRoomSize(0.5f);
    reverb->setMix(0.3f);
    effects[REVERBINDEX] = reverb;
    
    Superpowered3BandEQ *eq = new Superpowered3BandEQ(44100);
    eq->bands[0] = 2.0f;
    eq->bands[1] = 0.5f;
    eq->bands[2] = 2.0f;
    effects[EQINDEX] = eq;
     */
    output = [[SuperpoweredIOSAudioIO alloc] initWithDelegate:(id<SuperpoweredIOSAudioIODelegate>)self preferredBufferSize:12 preferredMinimumSamplerate:44100 audioSessionCategory:AVAudioSessionCategoryPlayback channels:2 audioProcessingCallback:audioProcessing clientdata:(__bridge void *)self];
    [output start];
    
    samplerate = 44100;
    bandsWritePos = bandsReadPos = bandsPos = lastNumberOfSamples = 0;
    memset(bands, 0, 128 * 16 * sizeof(float));
    
    float frequencies[16] = { 35, 50, 70, 100, 155, 220, 270, 311, 370, 440, 550, 622, 880, 1244, 1760, 2489};
    float widths[16] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 };
    filters = new SuperpoweredBandpassFilterbank(16, frequencies, widths, samplerate);
    return self;
}

- (void)getFrequencies:(float *)freqs {
    pthread_mutex_lock(&mutex);
    memset(freqs, 0, 16 * sizeof(float));
    unsigned int currentPosition = __sync_fetch_and_add(&bandsPos, 0);
    if (currentPosition > bandsReadPos) {
        unsigned int positionsElapsed = currentPosition - bandsReadPos;
        float multiplier = 1.0f / float(positionsElapsed * lastNumberOfSamples);
        while (positionsElapsed--) {
            float *b = &bands[bandsReadPos++ & 127][0];
            for (int n = 0; n < 16; n++) freqs[n] += b[n] * multiplier;
        }
    }
    pthread_mutex_unlock(&mutex);
}

@end
