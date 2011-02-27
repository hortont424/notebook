/*
 * Copyright 2011 Tim Horton. All rights reserved.
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

#import <Cocoa/Cocoa.h>
#import <BWToolkitFramework/BWToolkitFramework.h>
#import <NBCore/NBCore.h>
#import <NBUI/NBUI.h>

@class MAAttachedWindow;

@interface NBDocument : NSDocument<NSWindowDelegate>
{
    NBNotebookView * notebookView;
    BWAnchoredButton * languageButton;
    BWSplitView * splitView;

    BOOL initialized;
    BOOL initializedFromFile;
    NBNotebook * notebook;

    NSSearchField * searchField;
    NSView * searchResultsView;
    MAAttachedWindow * searchWindow;
}

@property (nonatomic,assign) IBOutlet NBNotebookView * notebookView;
@property (nonatomic,assign) IBOutlet BWAnchoredButton * languageButton;
@property (nonatomic,assign) IBOutlet BWSplitView * splitView;

@property (nonatomic,assign) BOOL initialized;
@property (nonatomic,assign) BOOL initializedFromFile;
@property (nonatomic,assign) NBNotebook * notebook;

@property (nonatomic,readonly) BOOL hasKeyCell;
@property (nonatomic,readonly) BOOL hasSelectedCell;
@property (nonatomic,readonly) BOOL keyCellIsRichText;

@property (nonatomic,assign) IBOutlet NSSearchField * searchField;
@property (nonatomic,assign) IBOutlet NSView * searchResultsView;

- (void)initDocumentWithEngineClass:(Class)engineClass withTemplate:(NSString *)template;

+ (NSString *)fileExtension;
+ (NSString *)fileTypeName;

- (IBAction)doSomethingButton:(id)sender;

- (NBCellView *)keyCellView;
- (NSArray *)selectedCellViews;

- (IBAction)increaseIndent:(id)sender;
- (IBAction)decreaseIndent:(id)sender;

- (IBAction)insertCell:(id)sender;
- (IBAction)deleteCell:(id)sender;
- (IBAction)splitCell:(id)sender;
- (IBAction)mergeCells:(id)sender;

- (IBAction)evaluateCells:(id)sender;
- (IBAction)abortEvaluation:(id)sender;

- (IBAction)selectAllCells:(id)sender;
- (IBAction)selectAllCellsAboveCurrent:(id)sender;
- (IBAction)selectAllCellsBelowCurrent:(id)sender;

- (IBAction)searchGlobals:(id)sender;

@end
