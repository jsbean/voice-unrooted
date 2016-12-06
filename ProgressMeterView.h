//
//  LevelMeterView.h
//  SimpleAudioPlayer
//
//  Created by Chris Adamson on 12/23/08.
//  Copyright 2008 Subsequently and Furthermore, Inc.. All rights reserved.
//
//
//  Licensed with the Apache 2.0 License
//  http://apache.org/licenses/LICENSE-2.0
//

// modiefied by Hans on 04/11/2010


#import <UIKit/UIKit.h>


@interface ProgressMeterView : UIView {
	float progressValue;
	CGColorRef levelColor;
	CGRect levelRect;
    BOOL colorInversion;
}
- (void) setProgress: (double) progressValue;
- (void) setProgress2: (double) progressValue;
- (void) setProgressColor: (CGColorRef) levelColor;

@end
