//
//  NBNotebookView.h
//  Notebook
//
//  Created by Tim Horton on 2010.11.17.
//  Copyright 2010 Rensselaer Polytechnic Institute. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "NBNotebook.h"
#import "NBCell.h"
#import "NBCellView.h"

@interface NBNotebookView : NSView
{
    IBOutlet NBNotebook * notebook;
    
    NSMutableArray * cellViews;
}

@property (assign) IBOutlet NBNotebook * notebook;

- (void)addViewForCell:(NBCell *)cell atIndex:(uint32_t)idx;
- (void)relayoutViews;

@end
