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

#import "NBCommentCellView.h"

#import "NBSettings.h"

@implementation NBCommentCellView

@synthesize textView;

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

        textView = [[NBCommentView alloc] initWithFrame:frameWithoutMargin];
        [textView setDelegate:self];
        [textView setFieldEditor:NO];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:NSTextDidChangeNotification object:textView];
        [self enableContentResizeNotifications];

        [self addSubview:textView];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NBSettings * settings = [NBSettings sharedInstance];
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];

    [super drawRect:dirtyRect];

    // Draw the background color over the left hand side of the cell

    [[settings colorWithSelector:@"background.comment"] setFill];
    CGContextFillRect(ctx, NSMakeRect(1, margin.top, margin.left, self.bounds.size.height - (margin.top + margin.bottom)));
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
    // If the NBCellView itself gets focus (someone clicks in the margin), give the contained text view focus instead

    [self.window makeFirstResponder:self.textView];

    return YES;
}

- (void)setCell:(NBCell *)inCell
{
    [super setCell:inCell];

    [cell addObserver:self forKeyPath:@"output" options:0 context:nil];
    [textView setString:cell.content];
    [textView display];

    [self subviewDidResize:nil];
}

- (void)textDidChange:(NSNotification *)aNotification
{
    // Someone typed into the text view, so our NBCell needs to be updated

    cell.content = [textView string];
}

- (void)clearSelection
{
    [textView setSelectedRange:NSMakeRange(0, 0)];
}

@end
