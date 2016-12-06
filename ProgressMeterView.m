//
//  LevelMeterView.m
//  SimpleAudioPlayer
//
//  Created by Chris Adamson on 12/23/08.
//  Copyright 2008 Subsequently and Furthermore, Inc.. All rights reserved.
//
//
//  Licensed with the Apache 2.0 License
//  http://apache.org/licenses/LICENSE-2.0
//
// modiefied by Hans on 4/11/2010

#import "ProgressMeterView.h"


@implementation ProgressMeterView



//**********************************************************
//**********************************************************
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

//**********************************************************
//**********************************************************
- (id)initWithCoder: (NSCoder*) decoder {
	if (self = [super initWithCoder: decoder]) {
		levelRect.origin.x=0;
		levelRect.origin.y=0;
	}
	return self;
}

//**********************************************************
//**********************************************************
-(void)setProgress: (double) progressV {
    colorInversion = NO;
	progressValue = progressV;
	// request redraw
	[self setNeedsDisplay];
}

//**********************************************************
//**********************************************************
-(void)setProgress2: (double) progressV {
    colorInversion = YES;
    
	progressValue = progressV;
	// request redraw
	[self setNeedsDisplay];
}

//**********************************************************
//**********************************************************
- (void)setProgressColor: (CGColorRef) levelC{
	levelColor = levelC;
}



//**********************************************************
//**********************************************************
- (void)drawRect:(CGRect)rect {
	// Drawing code
    
    if (colorInversion) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // erase view
        CGColorRef undrawColor = levelColor;
        CGContextSetFillColorWithColor (context, undrawColor);
        CGContextFillRect (context, rect);
        
        // figure out how far to draw
        levelRect.size.height = rect.size.height;
        levelRect.origin.x = (progressValue * rect.size.width);
        levelRect.size.width = rect.size.width;
        
        // fill with color
        CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
        CGContextFillRect(context, levelRect);
        
    } else {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // erase view
        CGColorRef undrawColor = self.backgroundColor.CGColor;
        CGContextSetFillColorWithColor (context, undrawColor);
        CGContextFillRect (context, rect);
        
        // figure out how far to draw
        levelRect.size.height = rect.size.height;
        levelRect.origin.x = (progressValue * rect.size.width);
        levelRect.size.width = rect.size.width;
        
        // fill with color
        CGContextSetFillColorWithColor(context, levelColor);
        CGContextFillRect(context, levelRect);
	}
}



@end
