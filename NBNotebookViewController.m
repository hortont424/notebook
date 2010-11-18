//
//  NBNotebookViewController.m
//  Notebook
//
//  Created by Tim Horton on 2010.11.17.
//  Copyright 2010 Rensselaer Polytechnic Institute. All rights reserved.
//

#import "NBNotebookViewController.h"

@implementation NBNotebookViewController

- (void)notebookView:(NBNotebookView *)notebookView addCell:(NBCell *)cell
{
    NSLog(@"notebookView:addCell:");
    
    [notebookView.notebook addCell:cell];
    [notebookView addViewForCell:cell atIndex:0]; // FIXME: 0 for now, is wrong!
}

@end
