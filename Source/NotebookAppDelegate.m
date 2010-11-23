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

#import "NotebookAppDelegate.h"

#import "NBCell.h"
#import "NBNotebook.h"
#import "NBCreateNotebookView.h"
#import "NBEngineLoader.h"

@implementation NotebookAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NBCreateNotebookView * newNotebook = [[NBCreateNotebookView alloc] init];
    [NSBundle loadNibNamed:@"NBCreateNotebookView" owner:newNotebook];
    newNotebook.delegate = self;
}

// TODO: why in the world does it seem that different notebooks are sharing globals!?!

- (void)createNotebookWithEngineClass:(Class)engineClass
{
    NBCell * cell;
    NBNotebookViewController * notebookController = [[NBNotebookViewController alloc] init];
    [NSBundle loadNibNamed:@"Notebook" owner:notebookController];
    
    NBNotebookView * notebookView = (NBNotebookView *)[notebookController view];
    
    [notebookView setNotebook:[[NBNotebook alloc] init]];
    [[notebookView notebook] setEngine:[[engineClass alloc] init]];
    
    cell = [[NBCell alloc] init];
    cell.content = @"import random";
    [notebookController notebookView:notebookView addCell:cell afterCellView:nil];
    
    cell = [[NBCell alloc] init];
    cell.content = @"def doSomethingRandom(max=5):\n    return random.uniform(0, max)";
    [notebookController notebookView:notebookView addCell:cell afterCellView:nil];
    
    cell = [[NBCell alloc] init];
    cell.content = @"print doSomethingRandom()";
    [notebookController notebookView:notebookView addCell:cell afterCellView:nil];
    
    cell = [[NBCell alloc] init];
    cell.content = @"for x in range(100000):\n    print x";
    [notebookController notebookView:notebookView addCell:cell afterCellView:nil];
    
    cell = [[NBCell alloc] init];
    cell.content = @"asdf = lambda x : x + 2\n\ndef asdf2():\n    print asdf(2), \"some random string\" # 4, definitely\n\nasdf2()";
    [notebookController notebookView:notebookView addCell:cell afterCellView:nil];
}

@end
