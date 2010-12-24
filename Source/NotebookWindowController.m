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

#import "NotebookWindowController.h"

#import "NBCreateNotebookView.h"
#import "NotebookDocument.h"

@implementation NotebookWindowController

- (void)windowDidLoad
{
    if(![[self document] initializedFromFile])
    {
        NBCreateNotebookView * createNotebookController = [[NBCreateNotebookView alloc] init];

        [NSBundle loadNibNamed:@"NBCreateNotebookView" owner:createNotebookController];

        createNotebookController.delegate = self;

        [[[self document] splitView] removeFromSuperview];

        NSRect viewBounds = [[createNotebookController mainView] bounds];
        NSRect winFrame = [[self window] frame];

        [[self window] setFrame:NSMakeRect(winFrame.origin.x - ((viewBounds.size.width - winFrame.size.width) / 2.0),
                                           winFrame.origin.y - ((viewBounds.size.height - winFrame.size.height) / 2.0),
                                           viewBounds.size.width,
                                           viewBounds.size.height) display:NO];
        [[self window] setMinSize:NSMakeSize([[self window] frame].size.width, 200)];
        [[self window] setMaxSize:NSMakeSize([[self window] frame].size.width, 800)];

        [[self window] setContentView:[createNotebookController mainView]];
    }
}

- (void)createNotebookWithEngineClass:(Class)engineClass
{
    NSRect viewBounds = [[[self document] splitView] bounds];
    NSRect winFrame = [[self window] frame];

    [[self document] initDocumentWithEngineClass:engineClass withTemplate:@"empty-cell"];

    [[self window] setFrame:NSMakeRect(winFrame.origin.x - ((viewBounds.size.width - winFrame.size.width) / 2.0),
                                       winFrame.origin.y - ((viewBounds.size.height - winFrame.size.height) / 2.0),
                                       viewBounds.size.width,
                                       viewBounds.size.height) display:YES animate:YES];

    [[self window] setContentView:[[self document] splitView]]; // TODO: the view transition should be smooth too!
}

@end
