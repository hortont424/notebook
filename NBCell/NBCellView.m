/*
 * Copyright 2010 Tim Horton. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY TIM HORTON "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
 * SHALL TIM HORTON OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 */

#import "NBCellView.h"

#import "NBSourceViewController.h"
#import "NBSettings.h"

@implementation NBCellView

@synthesize cell;
@synthesize delegate;
@synthesize state;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        margin = NSMakeSize(4, 1); // TODO: make it a setting!
        state = NBCellViewChanged;
    }
    return self;
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)enableContentResizeNotifications
{
    
}

- (void)disableContentResizeNotifications
{
    
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [self becomeFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    return YES;
}


- (void)setCell:(NBCell *)inCell
{
    cell = inCell;
    
    [cell addObserver:self forKeyPath:@"output" options:0 context:nil];
}

- (void)setState:(NBCellViewState)inState
{
    state = inState;
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NBSettings * settings = [NBSettings sharedInstance];
    
    // Draw the cell background
    
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 0.2);
    CGContextFillRect(ctx, [self bounds]);
    
    // Draw the cell state indicator (right hand side of the cell)
    
    switch(self.state)
    {
        case NBCellViewChanged:
            [settings.statusDefaultColor setFill];
            break;
        case NBCellViewEvaluating:
            [settings.statusBusyColor setFill];
            break;
        case NBCellViewFailed:
            [settings.statusFailureColor setFill];
            break;
        case NBCellViewSuccessful:
            [settings.statusSuccessColor setFill];
            break;
    }
    
    CGContextFillRect(ctx, NSMakeRect(0, margin.height, margin.width, self.bounds.size.height - (margin.height * 2)));
    CGContextFillRect(ctx, NSMakeRect(self.bounds.size.width - margin.width, margin.height, margin.width, self.bounds.size.height - (margin.height * 2)));
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
}

- (float)requestedHeight
{
    float height = 0.0;
    
    return height;

}

- (void)clearSelection
{

}

@end
