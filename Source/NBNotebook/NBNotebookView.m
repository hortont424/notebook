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

#import "NBSourceCellView.h"
#import "NBCommentCellView.h"
#import "NBSettings.h"

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
    [self relayoutViewsWithAnimation:NO];
}

- (NBCellView *)addViewForCell:(NBCell *)cell afterCellView:(NBCellView *)afterCellView withAnimation:(BOOL)animation
{
    NSUInteger insertionIndex = NSNotFound;
    
    NBCellView * cellView;
    
    switch(cell.type)
    {
        case NBCellSnippet:
            cellView = [[NBSourceCellView alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, 12)];
            break;
        case NBCellComment:
            cellView = [[NBCommentCellView alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, 12)];
            break;
        default:
            NSLog(@"Unknown cell type %d", cell.type);
            break;
    }
    
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
    [cellView setFrameOrigin:NSMakePoint(0, [self yForView:cellView])];
    
    [self relayoutViewsWithAnimation:animation];
    
    return cellView;
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
    [[NSCursor resizeDownCursor] push];
}

- (void)mouseExited:(NSEvent *)theEvent
{   
    appendingCellView = nil;
    [NSCursor pop];
}

- (float)yForView:(NBCellView *)cellView
{
    NBSettings * settings = [NBSettings sharedInstance];
    float cellSpacing = [[settings settingsWithSelector:@"cellSpacing"] floatValue];
    float y = 0;
    
    for(NBCellView * v in cellViews)
    {
        if(v == cellView)
            return y;
        
        y += [v requestedHeight] + cellSpacing;
    }
    
    return 0;
}

- (void)relayoutViewsWithAnimation:(BOOL)animation
{
    NBSettings * settings = [NBSettings sharedInstance];
    
    float cellSpacing = [[settings settingsWithSelector:@"cellSpacing"] floatValue];
    float cellAnimationSpeed = [[settings settingsWithSelector:@"cellAnimationSpeed"] floatValue];
    
    NSSize totalSize = NSZeroSize;
    totalSize.width = self.frame.size.width;
    
    for(NSTrackingArea * trackingArea in addCellTrackingAreas)
    {
        [self removeTrackingArea:trackingArea];
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:cellAnimationSpeed];
    
    for(NBCellView * cellView in cellViews)
    {
        NSTrackingArea * trackingArea;
        NSRect trackingRect;
        float requestedHeight = [cellView requestedHeight];
        
        if(animation)
        {
            [[cellView animator] setFrame:NSMakeRect(0, totalSize.height, totalSize.width, requestedHeight)];
        }
        else
        {
            [cellView setFrame:NSMakeRect(0, totalSize.height, totalSize.width, requestedHeight)];
        }
        
        totalSize.height += requestedHeight + cellSpacing;
        
        trackingRect = NSMakeRect(0, totalSize.height - cellSpacing, totalSize.width, cellSpacing);
        trackingArea = [[NSTrackingArea alloc] initWithRect:trackingRect
                                                    options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow)
                                                      owner:self
                                                   userInfo:[NSDictionary dictionaryWithObject:cellView forKey:@"cellView"]];
        
        [self addTrackingArea:trackingArea];
        [addCellTrackingAreas addObject:trackingArea];
    }
    
    [NSAnimationContext endGrouping];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:self];
    [self setFrameSize:totalSize];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidResize:) name:NSViewFrameDidChangeNotification object:self];
}

- (void)cellViewResized:(NBCellView *)cellView
{
    [self relayoutViewsWithAnimation:NO];
}

- (void)evaluateCellView:(NBCellView *)cellView
{
    [delegate notebookView:self evaluateCellView:cellView];
}

- (void)cellViewTookFocus:(NBCellView *)cellView
{
    for(NBCellView * defocusView in cellViews)
    {
        if(defocusView == cellView)
            continue;
    
        [defocusView clearSelection];
    }
}

@end
