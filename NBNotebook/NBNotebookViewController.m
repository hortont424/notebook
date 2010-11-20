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

#import "NBNotebookViewController.h"

@implementation NBNotebookViewController

- (id)init
{
    self = [super init];
    
    if(self != nil)
    {
        engines = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (NBCellView *)notebookView:(NBNotebookView *)notebookView addCell:(NBCell *)cell afterCellView:(NBCellView *)afterCellView
{
    [notebookView.notebook addCell:cell];
    return [notebookView addViewForCell:cell afterCellView:(NBCellView *)afterCellView];
}

- (id<NBEngine>)engineForNotebookView:(id)notebookView
{
    id<NBEngine> engine = nil;
    
    engine = [engines objectForKey:[NSNumber numberWithLong:(long)notebookView]]; // TODO: HORRIBLE (prevents copy)
    
    if(!engine)
    {
        engine = [[NBPythonEngine alloc] init]; // TODO: pluggable!
        [engines setObject:engine forKey:[NSNumber numberWithLong:(long)notebookView]]; // TODO: HORRIBLE (prevents copy)
    }
    
    return engine;
}

- (void)notebookView:(id)notebookView evaluateCellView:(NBCellView *)cellView
{
    id<NBEngine> engine = [self engineForNotebookView:notebookView];
    
    [engine executeSnippet:cellView.cell.content onCompletion:^(NBException * exception) { [cellView evaluationComplete:exception]; }];
}

- (NBCellView *)notebookView:(id)notebookView addNewCellAfterCell:(NBCellView *)cellView
{
    NBCell * newCell = [[NBCell alloc] init];
    NBCellView * newCellView;
    
    newCell.content = @"";
    
    newCellView = [self notebookView:notebookView addCell:newCell afterCellView:cellView];
    
    [[newCellView window] makeFirstResponder:newCellView];
    
    return newCellView;
}

@end
