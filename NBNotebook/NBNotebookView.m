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

#import "NBNotebookView.h"

#import "NBCellView.h"

@implementation NBNotebookView

@synthesize notebook;
@synthesize delegate;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        cellViews = [[NSMutableArray alloc] init];
        addCellTrackingAreas = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidResize:) name:NSViewFrameDidChangeNotification object:self];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)viewDidResize:(NSNotification *)aNotification
{
    [self relayoutViews];
}

- (void)addViewForCell:(NBCell *)cell afterCellView:(NBCellView *)afterCellView
{
    NSUInteger insertionIndex = NSNotFound;
    
    NBCellView * cellView = [[NBCellView alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, 12)];
    cellView.cell = cell;
    cellView.delegate = self;
    
    if(afterCellView)
    {
        insertionIndex = [cellViews indexOfObject:afterCellView] + 1;
    }
    
    if(insertionIndex == NSNotFound)
    {
        insertionIndex = [cellViews count];
    }
    
    [cellViews insertObject:cellView atIndex:insertionIndex];
    
    [self addSubview:cellView];
    
    [self relayoutViews];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if(appendingCellView)
    {
        [delegate notebookView:self addNewCellAfterCell:appendingCellView];
    }
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    appendingCellView = (NBCellView *)[(NSDictionary *)[theEvent userData] objectForKey:@"cellView"];
}

- (void)mouseExited:(NSEvent *)theEvent
{   
    appendingCellView = nil;
}

- (void)relayoutViews
{
    NSSize totalSize = NSZeroSize;
    
    totalSize.width = self.frame.size.width;
    
    for(NSTrackingArea * trackingArea in addCellTrackingAreas)
    {
        [self removeTrackingArea:trackingArea];
    }
    
    for(NBCellView * cellView in cellViews)
    {
        NSTrackingArea * trackingArea;
        
        [cellView setFrame:NSMakeRect(0, totalSize.height, totalSize.width, [cellView requestedHeight])];
        
        totalSize.height += [cellView requestedHeight] + 4; // TODO: make 4 a parameter
        
        trackingArea = [[NSTrackingArea alloc] initWithRect:NSMakeRect(0, totalSize.height - 4, totalSize.width, 4)
                                                    options:(NSTrackingMouseEnteredAndExited|NSTrackingActiveInKeyWindow)
                                                      owner:self
                                                   userInfo:[NSDictionary dictionaryWithObject:cellView forKey:@"cellView"]];
        
        [self addTrackingArea:trackingArea];
        [addCellTrackingAreas addObject:trackingArea];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:self];
    [self setFrameSize:totalSize];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidResize:) name:NSViewFrameDidChangeNotification object:self];
}

- (void)cellViewResized:(NBCellView *)cellView
{
    [self relayoutViews];
}

- (void)evaluateCellView:(NBCellView *)cellView
{
    [delegate notebookView:self evaluateCellView:cellView];
}

@end
