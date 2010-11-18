//
//  NBNotebookView.m
//  Notebook
//
//  Created by Tim Horton on 2010.11.17.
//  Copyright 2010 Rensselaer Polytechnic Institute. All rights reserved.
//

#import "NBNotebookView.h"

@implementation NBNotebookView

@synthesize notebook;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        cellViews = [[NSMutableArray alloc] init];
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

- (void)addViewForCell:(NBCell *)cell atIndex:(uint32_t)idx
{
    NBCellView * cellView = [[NBCellView alloc] init];
    cellView.cell = cell;
    cellView.parent = self;
    [cellViews addObject:cellView];
    
    [self addSubview:cellView];
    
    [self relayoutViews];
}

- (void)relayoutViews
{
    NSSize totalSize = NSZeroSize;
    
    for(NBCellView * cellView in cellViews)
    {
        float requestedHeight = [cellView requestedHeight];
        
        [cellView setFrame:NSMakeRect(0, totalSize.height, [self frame].size.width, requestedHeight)];
        totalSize.height += requestedHeight + 3;
    }
    
    totalSize.width = [self frame].size.width;
    
    [self setFrameSize:totalSize];
}

@end
