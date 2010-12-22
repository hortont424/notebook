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

#import <Carbon/Carbon.h>

#import "NBNotebookView.h"

#import "NBSourceCellView.h"
#import "NBCommentCellView.h"
#import "NBSettings.h"

@implementation NBNotebookView

@synthesize notebook;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];

    if(self)
    {
        cellViews = [NSMapTable mapTableWithStrongToStrongObjects];
        selectedCellViews = [[NSMutableArray alloc] init];
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

- (void)setNotebook:(NBNotebook *)inNotebook
{
    notebook = inNotebook;

    notebook.delegate = self;
}

- (void)viewDidResize:(NSNotification *)aNotification
{
    [self relayoutViews];
}

- (void)cellAdded:(NBCell *)cell atIndex:(NSUInteger)index
{
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

    [cellViews setObject:cellView forKey:cell];

    [self addSubview:cellView];
    [cellView setFrameOrigin:NSMakePoint(0, [self yForView:cellView])];

    [self relayoutViews];
}

- (void)cellRemoved:(NBCell *)cell
{
    [[cellViews objectForKey:cell] removeFromSuperview];
    [cellViews removeObjectForKey:cell];

    [self relayoutViews];
}

- (void)keyDown:(NSEvent *)theEvent
{
    BOOL handled = NO;

    switch([theEvent keyCode])
    {
        case kVK_Delete: // TODO: all keyboard shortcuts should be adjustable
            for(NBCellView * selectedCellView in selectedCellViews)
            {
                [notebook removeCell:selectedCellView.cell];
            }

            handled = YES;
            break;
        case kVK_Return:
            if([theEvent modifierFlags] & NSShiftKeyMask)
            {
                for(NBCellView * selectedCellView in selectedCellViews)
                {
                    [selectedCellView evaluate];
                }

                handled = YES;
            }
            break;
    }

    if(!handled)
    {
        [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
    }
}

- (void)mouseDown:(NSEvent *)theEvent
{
    // TODO: need to be able to add different kinds of cells

    if(appendingCellView)
    {
        NBCell * newCell = [[NBCell alloc] init];
        newCell.content = @"";

        if((NSNull *)appendingCellView == [NSNull null])
        {
            [notebook addCell:newCell atIndex:0];
        }
        else
        {
            [notebook addCell:newCell afterCell:appendingCellView.cell];
        }
    }
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    NSDictionary * userData = (NSDictionary *)[theEvent userData];

    if([[userData objectForKey:@"reason"] isEqualToString:@"addCell"])
    {
        appendingCellView = (NBCellView *)[userData objectForKey:@"cellView"];
        [[NSCursor resizeDownCursor] push];
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    NSDictionary * userData = (NSDictionary *)[theEvent userData];

    if([[userData objectForKey:@"reason"] isEqualToString:@"addCell"])
    {
        appendingCellView = nil;
        [NSCursor pop];
    }
}

- (float)yForView:(NBCellView *)cellView
{
    NBSettings * settings = [NBSettings sharedInstance];
    float cellSpacing = [[settings settingsWithSelector:@"cellSpacing"] floatValue];
    float y = cellSpacing;

    for(NBCell * cell in notebook.cells)
    {
        NBCellView * otherView = [cellViews objectForKey:cell];

        if(otherView == cellView)
            return y;

        y += [otherView requestedHeight] + cellSpacing;
    }

    return 0;
}

- (void)relayoutViews
{
    NBSettings * settings = [NBSettings sharedInstance];

    float cellSpacing = [[settings settingsWithSelector:@"cellSpacing"] floatValue];

    NSTrackingArea * trackingArea;
    NSRect trackingRect;

    NSSize totalSize = NSZeroSize;
    totalSize.height = cellSpacing; // TODO: use yForView for these
    totalSize.width = self.frame.size.width;

    for(NSTrackingArea * trackingArea in addCellTrackingAreas)
    {
        [self removeTrackingArea:trackingArea];
    }

    [addCellTrackingAreas removeAllObjects];

    trackingRect = NSMakeRect(0, totalSize.height - cellSpacing, totalSize.width, cellSpacing);
    trackingArea = [[NSTrackingArea alloc] initWithRect:trackingRect
                                                options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow)
                                                  owner:self
                                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNull null],@"cellView",@"addCell",@"reason",nil]];

    [self addTrackingArea:trackingArea];
    [addCellTrackingAreas addObject:trackingArea];

    for(NBCell * cell in notebook.cells)
    {
        NBCellView * cellView = [cellViews objectForKey:cell];
        float requestedHeight = [cellView requestedHeight];

        [cellView setFrame:NSMakeRect(0, totalSize.height, totalSize.width, requestedHeight)];

        totalSize.height += requestedHeight + cellSpacing;

        trackingRect = NSMakeRect(0, totalSize.height - cellSpacing, totalSize.width, cellSpacing);
        trackingArea = [[NSTrackingArea alloc] initWithRect:trackingRect
                                                    options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow)
                                                      owner:self
                                                   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:cellView,@"cellView",@"addCell",@"reason",nil]];

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
    if([cellView isKindOfClass:[NBSourceCellView class]])
    {
        [notebook.engine executeSnippet:cellView.cell.content onCompletion:^(NBException * exception, NSString * output) {
            [(NBSourceCellView *)cellView evaluationComplete:exception withOutput:output];
        }];
    }
}

- (void)cellViewTookFocus:(NBCellView *)cellView
{
    for(NBCellView * defocusView in [cellViews objectEnumerator])
    {
        if(defocusView == cellView)
            continue;

        [defocusView clearSelection];
    }

    [self selectedCell:nil];
}

- (void)selectedCell:(NBCellView *)cellView
{
    for(NBCellView * defocusView in [cellViews objectEnumerator])
    {
        [defocusView clearSelection];
    }

    if(cellView)
    {
        [[self window] makeFirstResponder:self];
    }

    for(NBCellView * deselectView in selectedCellViews)
    {
        if(deselectView == cellView)
            continue;

        deselectView.selected = NO;
    }

    [selectedCellViews removeAllObjects];

    if(cellView)
    {
        [selectedCellViews addObject:cellView];
    }
}

@end
