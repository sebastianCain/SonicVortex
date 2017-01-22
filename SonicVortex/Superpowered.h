// This object handles Superpowered.
// Compare the source to CoreAudio.mm and see how much easier it is to understand.
#import "SuperpoweredPerformance-Prefix.pch"

@interface Superpowered: NSObject {
@public
    bool playing;
    uint64_t avgUnitsPerSecond, maxUnitsPerSecond;
}

// Updates the user interface according to the file player's state.
- (void)updatePlayerLabel:(UILabel *)label slider:(UISlider *)slider button:(UIButton *)button;

- (void)togglePlayback; // Play/pause.
- (void)seekTo:(float)percent; // Jump to a specific position.

- (void)toggle; // Start/stop Superpowered.
- (bool)toggleFx:(float)cadence; // Enable/disable fx.

@end
