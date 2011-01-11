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
#import <NBCore/NBCore.h>

#import "NBCreateNotebookView.h"

@implementation NBCreateNotebookView

@synthesize languageChooser, delegate, mainView, engineClasses;

- (void)awakeFromNib
{
    engineClasses = [[[NBEngineLoader sharedInstance] engineClasses] allValues];
    engineClasses = [engineClasses sortedArrayUsingComparator:^(id a, id b)
                     {
                         return [[a name] compare:[b name]];
                     }];
    NSRect windowFrame = [mainView frame];

    // TODO: magic numbers
    windowFrame.size.height = 64 + (([engineClasses count] > 3 ? 3 : [engineClasses count]) * 64);

    // set up the language chooser
    [languageChooser reloadData];
    [languageChooser setAllowsEmptySelection:NO];
    [languageChooser setSelectionIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];

    [[self window] setFrame:windowFrame display:YES];
}

- (IBAction)chooseSelectedLanguage:(id)sender
{
    NSIndexSet * indices = [languageChooser selectionIndexes];

    if([indices count])
    {
        [self chooseEngineClass:[engineClasses objectAtIndex:[indices firstIndex]]];
    }
}

- (IBAction)chooseEngineClass:(id)engineClass
{
    [delegate createNotebookWithEngineClass:engineClass];
}

- (IBAction)openExistingNotebook:(id)sender
{
    [delegate openExistingNotebook];
}

- (IBAction)cancelCreateNotebook:(id)sender
{
    [delegate cancelCreateNotebook];
}

// image browser delegate methods
- (void)imageBrowser:(IKImageBrowserView*)aBrowser cellWasDoubleClickedAtIndex:(NSUInteger)index
{
    [self chooseEngineClass:[engineClasses objectAtIndex:index]];
}

// image browser data source methods
- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *)aBrowser
{
	return [engineClasses count];
}

- (id)imageBrowser:(IKImageBrowserView *)aBrowser itemAtIndex:(NSUInteger)index
{
	return [engineClasses objectAtIndex:index];
}

@end
