//
//  SonicVortex-Swift.h
//  SonicVortex
//
//  Created by Sebastian Cain on 1/21/17.
//  Copyright © 2017 Sebastian Cain. All rights reserved.
//

#ifndef SonicVortex_Bridging_Header_h
#define SonicVortex_Bridging_Header_h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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
- (bool)toggleFx; // Enable/disable fx.
- (void)updateCadence:(double)cadence;
- (void)getFrequencies:(float *)freqs;
@end

#endif /* SonicVortex_Bridging_Header_h */
