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
        margin.left = 4; // TODO: make it a setting!
        margin.right = 10;
        margin.top = 1;
        margin.bottom = 1;
        
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
    NSPoint mouseLoc = [self convertPoint:[[self window] mouseLocationOutsideOfEventStream] fromView:nil];
    
    if(mouseLoc.x > self.frame.size.width - margin.right)
    {
        // We're in the selection box
        
        self.selected = YES;
    }
    else
    {
        [self becomeFirstResponder];
    }
}

- (BOOL)becomeFirstResponder
{
    return YES;
}

- (void)setSelected:(bool)inSelected
{
    selected = inSelected;
    
    if(selected)
    {
        [delegate selectedCell:self];
    }
    
    [self setNeedsDisplay:YES];
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
    
    CGContextFillRect(ctx, NSMakeRect(0, margin.top, margin.left, self.bounds.size.height - (margin.top + margin.bottom)));
    
    // Draw the selection indicator (right hand side of the cell)
    
    if(self.selected)
    {
        [[settings colorWithSelector:@"cell.selected"] setFill];
    }
    else
    {
        [[settings colorWithSelector:@"cell.unselected"] setFill];
    }

    CGContextFillRect(ctx, NSMakeRect(self.bounds.size.width - margin.right, margin.top, margin.right, self.bounds.size.height - (margin.top + margin.bottom)));
}

- (float)requestedHeight
{
    float height = margin.top;
    
    for(NSView * subview in [self subviews])
    {
        height += subview.frame.size.height + margin.bottom;
    }
    
    return height;
    
}

- (void)subviewDidResize:(NSNotification *)aNotification
{
    float currentY = margin.top;
    
    [self disableContentResizeNotifications];
    
    for(NSView * subview in [self subviews])
    {
        [subview setFrameOrigin:NSMakePoint(margin.left, currentY)];
        currentY = subview.frame.origin.y + subview.frame.size.height + margin.bottom;
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

- (void)deselectCell
{
    self.selected = NO;
}

@end
