//
//  NBSourceView.m
//  Notebook
//
//  Created by Tim Horton on 2010.11.18.
//  Copyright 2010 Rensselaer Polytechnic Institute. All rights reserved.
//

#import "NBSourceView.h"

@implementation NBSourceView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        // Initialization code here.
    }
    
    return self;
}

- (void)keyDown:(NSEvent *)theEvent
{
    BOOL handled = NO;
    
    switch([theEvent keyCode])
    {
        case 36:
            if([theEvent modifierFlags] & NSShiftKeyMask)
            {
                NSLog(@"newline");
                handled = YES;
            }
            break;
    }
    
    if(!handled)
    {
        [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
    }
}

@end
