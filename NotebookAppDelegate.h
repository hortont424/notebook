//
//  NotebookAppDelegate.h
//  Notebook
//
//  Created by Tim Horton on 2010.11.17.
//  Copyright 2010 Rensselaer Polytechnic Institute. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "NBNotebookView.h"
#import "NBNotebookController.h"

@interface NotebookAppDelegate : NSObject <NSApplicationDelegate>
{
    NSWindow * window;
    NBNotebookView * notebookView;
    NBNotebookController * notebookController;
}

@property (assign) IBOutlet NSWindow * window;
@property (assign) IBOutlet NBNotebookView * notebookView;
@property (assign) IBOutlet NBNotebookController * notebookController;

@end
