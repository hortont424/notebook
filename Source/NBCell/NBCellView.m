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

#import "NBSettings.h"

@implementation NBCellView

@synthesize cell;
@synthesize delegate;
@synthesize state;
@synthesize selected;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        margin = NSMakeSize(4, 1); // TODO: make it a setting!
        state = NBCellViewChanged;
        selected = NO;
    }
    return self;
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)enableContentResizeNotifications
{
    for(NSView * subview in [self subviews])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subviewDidResize:) name:NSViewFrameDidChangeNotification object:subview];
    }
}

- (void)disableContentResizeNotifications
{
    for(NSView * subview in [self subviews])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:subview];
    }
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
}

- (void)setState:(NBCellViewState)inState
{
    state = inState;
    
    [self setNeedsDisplay:YES];
}

- (void)evaluate
{
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    NBSettings * settings = [NBSettings sharedInstance];
    
    // Draw the cell background
    
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetRGBFillColor(ctx, 0.8, 0.8, 0.8, 1.0); // TODO: make this a setting
    CGContextFillRect(ctx, [self bounds]);
    
    // Draw the cell state indicator (left hand side of the cell)
    
    switch(self.state)
    {
        case NBCellViewChanged:
            [[settings colorWithSelector:@"status.default"] setFill];
            break;
        case NBCellViewEvaluating:
            [[settings colorWithSelector:@"status.busy"] setFill];
            break;
        case NBCellViewFailed:
            [[settings colorWithSelector:@"status.failure"] setFill];
            break;
        case NBCellViewSuccessful:
            [[settings colorWithSelector:@"status.success"] setFill];
            break;
    }
    
    CGContextFillRect(ctx, NSMakeRect(0, margin.height, margin.width, self.bounds.size.height - (margin.height * 2)));
    
    // Draw the selection indicator (right hand side of the cell)
    
    if(self.selected)
    {
        [[settings colorWithSelector:@"cell.selected"] setFill];
    }
    else
    {
        [[settings colorWithSelector:@"cell.unselected"] setFill];
    }

    CGContextFillRect(ctx, NSMakeRect(self.bounds.size.width - margin.width, margin.height, margin.width, self.bounds.size.height - (margin.height * 2)));
}

- (float)requestedHeight
{
    float height = margin.height;
    
    for(NSView * subview in [self subviews])
    {
        height += subview.frame.size.height + margin.height;
    }
    
    return height;
    
}

- (void)subviewDidResize:(NSNotification *)aNotification
{
    float currentY = margin.height;
    
    [self disableContentResizeNotifications];
    
    for(NSView * subview in [self subviews])
    {
        [subview setFrameOrigin:NSMakePoint(margin.width, currentY)];
        currentY = subview.frame.origin.y + subview.frame.size.height + margin.height;
    }
    
    [self enableContentResizeNotifications];
    
    [delegate cellViewResized:self];
}

- (void)subviewBecameFirstResponder:(id)subview
{
    // Clear selection in all the other cells
    
    [delegate cellViewTookFocus:self];
}

- (void)clearSelection
{
    [self doesNotRecognizeSelector:_cmd];
}

@end
