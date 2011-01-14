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
#import "NBCellSubview.h"

@implementation NBCellView

@synthesize cell;
@synthesize delegate;
@synthesize selected;
@synthesize selectionHandleHighlight;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];

    if(self)
    {
        margin.left = 4; // TODO: make it a setting!
        margin.right = 10;
        margin.top = 1;
        margin.bottom = 1;

        selected = NO;

        selectionHandleTrackingArea = nil;

        [self setPostsFrameChangedNotifications:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidResize:) name:NSViewFrameDidChangeNotification object:self];
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

- (void)viewDidResize:(id)sender
{
    if(selectionHandleTrackingArea)
    {
        [self removeTrackingArea:selectionHandleTrackingArea];
    }

    NSRect trackingRect = NSMakeRect(self.frame.size.width - margin.right, 0, margin.right, self.frame.size.height);

    selectionHandleTrackingArea = [[NSTrackingArea alloc] initWithRect:trackingRect
                                                options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow)
                                                  owner:self
                                               userInfo:[NSDictionary dictionaryWithObject:@"selectionHandle" forKey:@"type"]];

    [self addTrackingArea:selectionHandleTrackingArea];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    NSDictionary * userData = (NSDictionary *)[theEvent userData];

    if([[userData objectForKey:@"type"] isEqualToString:@"selectionHandle"])
    {
        self.selectionHandleHighlight = YES;
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    NSDictionary * userData = (NSDictionary *)[theEvent userData];

    if([[userData objectForKey:@"type"] isEqualToString:@"selectionHandle"])
    {
        self.selectionHandleHighlight = NO;
    }
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if(selectionHandleHighlight)
    {
        if(!([theEvent modifierFlags] & NSCommandKeyMask || [theEvent modifierFlags] & NSShiftKeyMask))
        {
            [[self delegate] deselectAll];
            self.selected = YES;
        }
        else
        {
            self.selected = !self.selected;
        }
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
    else
    {
        [delegate deselectedCell:self];
    }


    [self setNeedsDisplay:YES];
}

- (void)setCell:(NBCell *)inCell
{
    cell = inCell;
}

- (void)setSelectionHandleHighlight:(bool)inSelectionHandleHighlight
{
    selectionHandleHighlight = inSelectionHandleHighlight;

    [self setNeedsDisplay:YES];
}

- (void)evaluate
{

}

- (void)drawRect:(NSRect)dirtyRect
{
    NBSettings * settings = [NBSettings sharedInstance];
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];

    // Draw the cell background

    if(self.selected)
    {
        [[settings colorWithSelector:@"cell.selected"] setFill];
    }
    else
    {
        if(self.selectionHandleHighlight)
        {
            [[[settings colorWithSelector:@"cell.selected"] colorWithAlphaComponent:0.5] setFill];
        }
        else
        {
            [[settings colorWithSelector:@"cell.unselected"] setFill];
        }
    }

    CGContextFillRect(ctx, [self bounds]);
}

- (float)requestedHeight
{
    float height = margin.top;

    for(NSView * subview in [self subviews])
    {
        if([subview conformsToProtocol:@protocol(NBCellSubview)])
        {
            height += [(NSView<NBCellSubview> *)subview requestedHeight] + margin.bottom;
        }
        else
        {
            height += subview.frame.size.height + margin.bottom;
        }
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

- (NSRange)editableCursorLocation
{
    return NSMakeRange(NSNotFound, 0);
}

- (void)clearSelection
{
    [self doesNotRecognizeSelector:_cmd];
}

@end
