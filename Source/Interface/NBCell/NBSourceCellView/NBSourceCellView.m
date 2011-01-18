/*
 * Copyright 2011 Tim Horton. All rights reserved.
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

#import "NBSourceCellView.h"

#import "NBSettings.h"
#import "NBSourceView.h"
#import "NBOutputView.h"

@implementation NBSourceCellView

@synthesize sourceView;
@synthesize outputView;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];

    if(self)
    {
        NSRect frameWithoutMargin = frame;
        frameWithoutMargin.size.width -= (margin.left + margin.right);
        frameWithoutMargin.size.height -= (margin.top + margin.bottom);
        frameWithoutMargin.origin.x += margin.left;
        frameWithoutMargin.origin.y += margin.top;

        sourceView = [[NBSourceView alloc] initWithFrame:frameWithoutMargin];
        [sourceView setFieldEditor:NO];
        [sourceView setDelegate:self];
        [sourceView setParentCellView:self];
        [[sourceView textContainer] setHeightTracksTextView:NO];

        outputView = [[NBOutputView alloc] initWithFrame:frameWithoutMargin];
        [outputView setFieldEditor:NO];
        [outputView setEditable:NO];
        [outputView setParentCellView:self];
        [[outputView textContainer] setHeightTracksTextView:NO];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:NSTextDidChangeNotification object:sourceView];
        [self enableContentResizeNotifications];

        [self addSubview:sourceView];
    }
    return self;
}

- (BOOL)isRichText
{
    return NO;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NBSettings * settings = [NBSettings sharedInstance];
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];

    [super drawRect:dirtyRect];

    // Draw the cell state indicator (left hand side of the cell)

    switch(cell.state)
    {
        case NBCellChangedState:
            [[settings colorWithKey:@"status.default"] setFill];
            break;
        case NBCellBusyState:
            [[settings colorWithKey:@"status.busy"] setFill];
            break;
        case NBCellFailureState:
            [[settings colorWithKey:@"status.failure"] setFill];
            break;
        case NBCellSuccessState:
            [[settings colorWithKey:@"status.success"] setFill];
            break;
    }

    CGContextFillRect(ctx, NSMakeRect(0, margin.top, margin.left, self.bounds.size.height - (margin.top + margin.bottom)));
}

- (void)viewDidResize:(id)sender
{
    [self disableContentResizeNotifications];

    for(NSView * subview in [self subviews])
    {
        [subview setFrameSize:NSMakeSize((self.frame.size.width - (margin.left + margin.right)), subview.frame.size.height)];
    }

    [self enableContentResizeNotifications];

    [super viewDidResize:sender];
}

- (BOOL)becomeFirstResponder
{
    // If the NBCellView itself gets focus (someone clicks in the margin), give the contained NBSourceView focus instead
    // TODO: give the NBOutputView focus if the click is closer to that

    [self.window makeFirstResponder:self.sourceView];

    return YES;
}

- (void)subviewBecameFirstResponder:(NSNotification *)aNotification
{
    [super subviewBecameFirstResponder:aNotification];

    // Clear selection in whichever view did *not* just get focus

    if([aNotification object] == sourceView)
    {
        [outputView setSelectedRange:NSMakeRange(0, 0)];
    }
    else if([aNotification object] == outputView)
    {
        [sourceView setSelectedRange:NSMakeRange(0, 0)];
    }
}

- (void)setCell:(NBCell *)inCell
{
    [super setCell:inCell];

    [cell addObserver:self forKeyPath:@"content" options:0 context:nil];
    [cell addObserver:self forKeyPath:@"output" options:0 context:nil];
    [cell addObserver:self forKeyPath:@"state" options:0 context:nil];
    [cell addObserver:self forKeyPath:@"exception" options:0 context:nil];

    [sourceView setString:cell.content];
    [sourceView display]; // sourceView needs to determine its proper size!

    [self subviewDidResize:nil];
}

- (void)textDidChange:(NSNotification *)aNotification
{
    // Someone typed into the NBSourceView, so our NBCell and evaluation are no longer valid

    cell.content = [sourceView string];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"exception"] && (object == cell))
    {
        [sourceView clearExceptions];

        if(cell.exception.line)
        {
            [sourceView addException:cell.exception];
        }
    }
    else if([keyPath isEqualToString:@"state"] && (object == cell))
    {
        [sourceView clearExceptions];

        [self setNeedsDisplay:YES];
    }
    else if([keyPath isEqualToString:@"content"] && (object == cell))
    {
        // Our NBCell's content has changed, so we need to update our NBSourceView to correspond

        if(cell.content)
        {
            NSRange currentSelection = [sourceView selectedRange];

            [sourceView setString:cell.content];

            if(currentSelection.location + currentSelection.length < [cell.content length])
            {
                [sourceView setSelectedRange:currentSelection];
            }

            [sourceView display];
        }

        [self subviewDidResize:nil]; // TODO: this function should probably be renamed/abstracted into two
    }
    else if([keyPath isEqualToString:@"output"] && (object == cell))
    {
        // Our NBCell's output has changed, so we need to update our NBOutputView to correspond

        if(cell.output && ([[self subviews] indexOfObject:outputView] == NSNotFound))
        {
            // There's output now, and there wasn't before: display our NBOutputView

            [self addSubview:outputView];
        }
        else if(!cell.output && ([[self subviews] indexOfObject:outputView] != NSNotFound))
        {
            // There's no output now, and there was before: hide our NBOutputView

            [outputView removeFromSuperview];
        }

        if(cell.output)
        {
            // Update the NBOutputView's displayed string, and force it to redraw so that the size is updated

            [outputView setString:cell.output];
            [outputView display];
        }

        [self subviewDidResize:nil]; // TODO: this function should probably be renamed/abstracted into two
    }
}

- (NSRange)editableCursorLocation
{
    NSResponder * firstResponder = [[NSApp keyWindow] firstResponder];

    if(firstResponder == sourceView)
    {
        return [sourceView selectedRange];
    }
    else if(firstResponder == outputView)
    {
        return NSMakeRange(NSNotFound, 0);
    }


    return [super editableCursorLocation];
}

- (void)clearSelection
{
    [sourceView setSelectedRange:NSMakeRange(0, 0)];
    [outputView setSelectedRange:NSMakeRange(0, 0)];
}

@end
