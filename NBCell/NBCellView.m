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

@implementation NBCellView

@synthesize cell;
@synthesize sourceView;
@synthesize outputView;
@synthesize controller;
@synthesize delegate;
@synthesize state;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        margin = NSMakeSize(4, 1);
        state = NBCellViewChanged;
        
        controller = [[[NSObjectController alloc] init] autorelease];
        
        NBSourceViewController * sourceViewController = [[NBSourceViewController alloc] init]; // TODO: wrong place
        sourceViewController.parent = self; // TODO: wrong? should be by method or something
        
        sourceView = [[NBSourceView alloc] initWithFrame:frame];
        [sourceView setFieldEditor:NO];
        [sourceView setDelegate:sourceViewController];
        [sourceView setFont:[NSFont fontWithName:@"Menlo" size:12]];
        [sourceView setTextContainerInset:NSMakeSize(10, 10)];
        [[sourceView textContainer] setHeightTracksTextView:NO];
        
        outputView = [[NSTextView alloc] initWithFrame:frame];
        [outputView setFieldEditor:NO];
        [outputView setDelegate:self];
        [outputView setFont:[NSFont fontWithName:@"Menlo" size:12]];
        [outputView setTextContainerInset:NSMakeSize(10, 10)];
        [outputView setBackgroundColor:[NSColor colorWithDeviceWhite:0.9 alpha:1.0]]; // TODO: recolor output based on success state

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:NSTextDidChangeNotification object:sourceView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidResize:) name:NSViewFrameDidChangeNotification object:self];
        [self enableContentResizeNotifications];
        
        [self addSubview:sourceView];
    }
    return self;
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)enableContentResizeNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sourceViewDidResize:) name:NSViewFrameDidChangeNotification object:sourceView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sourceViewDidResize:) name:NSViewFrameDidChangeNotification object:outputView];
}

- (void)disableContentResizeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:sourceView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:outputView];
}

- (BOOL)becomeFirstResponder
{
    [self.window makeFirstResponder:self.sourceView];
    
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [self becomeFirstResponder];
}

- (void)setCell:(NBCell *)inCell
{
    cell = inCell;
    
    [cell addObserver:self forKeyPath:@"output" options:0 context:nil];
    
    [sourceView setString:cell.content];
    [sourceView display]; // sourceView needs to determine its proper size!
    
    [self sourceViewDidResize:nil];
}

- (void)setState:(NBCellViewState)inState
{
    state = inState;
    
    [self setNeedsDisplay:YES];
}

- (void)evaluate
{
    self.state = NBCellViewEvaluating;
    
    [delegate evaluateCellView:self];
    
    cell.output = nil;
}

- (void)evaluationComplete:(NBException *)exception
{
    if(exception)
    {
        // TODO: highlight line/character where exception occurred
        cell.output = [NSString stringWithFormat:@"%@", exception.message, nil];
    }
    
    self.state = exception ? NBCellViewFailed : NBCellViewSuccessful;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Draw the cell background
    
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 0.2);
    CGContextFillRect(ctx, [self bounds]);
    
    // Draw the cell state indicator (right hand side of the cell)
    
    switch(self.state)
    {
        case NBCellViewChanged:
            CGContextSetRGBFillColor(ctx, 0.729, 0.741, 0.714, 1.0);
            break;
        case NBCellViewEvaluating:
            CGContextSetRGBFillColor(ctx, 0.988, 0.914, 0.310, 1.0);
            break;
        case NBCellViewFailed:
            CGContextSetRGBFillColor(ctx, 0.788, 0.000, 0.000, 1.0);
            break;
        case NBCellViewSuccessful:
            CGContextSetRGBFillColor(ctx, 0.451, 0.824, 0.086, 1.0);
            break;
    }
    
    CGContextFillRect(ctx, NSMakeRect(0, margin.height, margin.width, self.bounds.size.height - (margin.height * 2)));
    CGContextFillRect(ctx, NSMakeRect(self.bounds.size.width - margin.width, margin.height, margin.width, self.bounds.size.height - (margin.height * 2)));
}

- (void)textDidChange:(NSNotification *)aNotification
{
    cell.content = [sourceView string];
    self.state = NBCellViewChanged;
    
    [self sourceViewDidResize:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"output"])
    {
        if(cell.output && ([[self subviews] indexOfObject:outputView] == NSNotFound))
        {
            [self addSubview:outputView];
        }
        else if(!cell.output && ([[self subviews] indexOfObject:outputView] != NSNotFound))
        {
            [outputView removeFromSuperview];
        }
        
        if(cell.output)
        {
            [outputView setString:cell.output];
            [outputView display];
        }
        
        [self sourceViewDidResize:nil]; // TODO: this function should probably be renamed/abstracted into two
    }
}

- (float)requestedHeight
{
    if(cell.output)
    {
        return sourceView.frame.size.height + outputView.frame.size.height + (margin.height * 3);
    }
    else
    {
        return sourceView.frame.size.height + (margin.height * 2);
    }

}

- (void)viewDidResize:(NSNotification *)aNotification
{
    [self disableContentResizeNotifications];
    
    [sourceView setFrameSize:NSMakeSize(self.frame.size.width - (margin.width * 2), sourceView.frame.size.height)];
    [outputView setFrameSize:NSMakeSize(self.frame.size.width - (margin.width * 2), outputView.frame.size.height)];
    
    [self enableContentResizeNotifications];
}

- (void)sourceViewDidResize:(NSNotification *)aNotification
{
    [self disableContentResizeNotifications];
    
    [sourceView setFrameOrigin:NSMakePoint(margin.width, margin.height)];
    [outputView setFrameOrigin:NSMakePoint(margin.width, sourceView.frame.origin.y + sourceView.frame.size.height + margin.height)];
    
    [self enableContentResizeNotifications];
    
    [delegate cellViewResized:self];
}

@end
