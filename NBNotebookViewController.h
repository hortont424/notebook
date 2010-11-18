//
//  NBNotebookViewController.h
//  Notebook
//
//  Created by Tim Horton on 2010.11.17.
//  Copyright 2010 Rensselaer Polytechnic Institute. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "NBNotebookView.h"
#import "NBCell.h"

@interface NBNotebookViewController : NSViewController
{

}

- (void)notebookView:(NBNotebookView *)notebookView addCell:(NBCell *)cell;

@end
