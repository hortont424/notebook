//
//  NotebookAppDelegate.m
//  Notebook
//
//  Created by Tim Horton on 2010.11.17.
//  Copyright 2010 Rensselaer Polytechnic Institute. All rights reserved.
//

#import "NotebookAppDelegate.h"

#import "NBCell.h"

@implementation NotebookAppDelegate

@synthesize window;
@synthesize notebookView;
@synthesize notebookController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NBCell * cell = [[NBCell alloc] init];
    cell.content = @"asdfasdfasdfasdfasadf";
    [notebookController notebookView:notebookView addCell:cell];
    
    cell = [[NBCell alloc] init];
    cell.content = @"asdfasdfasdfasdfasadf";
    [notebookController notebookView:notebookView addCell:cell];
}

@end
