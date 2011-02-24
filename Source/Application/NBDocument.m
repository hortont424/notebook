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

#import "NBDocument.h"

#import "NBWindowController.h"
#import "NBDocumentController.h"

@implementation NBDocument

@synthesize notebookView;
@synthesize languageButton;
@synthesize splitView;
@synthesize initialized;
@synthesize initializedFromFile;
@synthesize notebook;

- (id)init
{
    self = [super init];

    if(self != nil)
    {
        initialized = initializedFromFile = NO;

        notebook = [[NBNotebook alloc] init];
    }

    return self;
}

- (void)setInitialized:(BOOL)inInitialized
{
    initialized = inInitialized;

    // Synchronize all window titles after initialization, so they'll include the language name

    for(NSWindowController * windowController in [self windowControllers])
    {
        [windowController synchronizeWindowTitleWithDocumentName];
    }
}

- (void)makeWindowControllers
{
    NBWindowController * windowController = [[NBWindowController alloc] initWithWindowNibPath:[[NSBundle bundleWithIdentifier:@"com.hortont.notebook.app"] pathForResource:@"Notebook" ofType:@"nib"] owner:self];

    [self addWindowController:windowController];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];

    [notebookView setNotebook:notebook];
}

- (void)finishLoadingFile:(NSDictionary *)userData
{
    [self initDocumentWithEngineClass:[userData objectForKey:@"engineClass"] withTemplate:nil];

    // We need to disable undo registration while creating the cells, otherwise a document will
    // appear as edited immediately after being loaded

    [[self undoManager] disableUndoRegistration];

    for(NBCell * cell in [userData objectForKey:@"cells"])
    {
        [notebook addCell:cell];
    }

    [[self undoManager] enableUndoRegistration];
}

+ (NSString *)fileExtension
{
    return @"txt";
}

+ (NSString *)fileTypeName
{
    return @"Notebook";
}

- (NSArray *)writableTypesForSaveOperation:(NSSaveOperationType)saveOperation
{
    return [NSArray arrayWithObject:[self fileType]];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    Class engineClass = [[NSDocumentController sharedDocumentController] engineClassForType:typeName];

    NSData * data = nil;

    if(engineClass)
    {
        NBEngineEncoder * encoder = [[[engineClass encoderClass] alloc] init];
        data = [encoder dataForCells:notebook.cells];
    }

    if(outError != nil)
    {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:nil];
	}

	return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    self.initializedFromFile = YES;

    Class engineClass = [[NSDocumentController sharedDocumentController] engineClassForType:typeName];

    if(engineClass)
    {
        NBEngineEncoder * encoder = [[[engineClass encoderClass] alloc] init];

        [[NSRunLoop mainRunLoop] performSelector:@selector(finishLoadingFile:)
                                          target:self
                                        argument:[NSDictionary dictionaryWithObjectsAndKeys:[encoder cellsFromData:data],@"cells",engineClass,@"engineClass",nil]
                                           order:0
                                           modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    }
    else
    {
        NSLog(@"Unknown file type: %@", typeName);

        if(outError != nil)
        {
            *outError = [NSError errorWithDomain:@"Notebook" code:1 userInfo:nil]; // TODO: better errors
        }

        return NO;
    }


    if(outError != nil)
    {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:nil];
	}

    return YES;
}

- (void)initDocumentWithEngineClass:(Class)engineClass withTemplate:(NSString *)template
{
    [notebook setEngine:[[engineClass alloc] init]];

    [languageButton setTitle:[engineClass name]];

    [self setFileType:NSStringFromClass([engineClass documentClass])];

    self.initialized = YES;

    // We need to disable undo registration while creating the cells, otherwise a document will
    // appear as edited immediately after being created

    [[self undoManager] disableUndoRegistration];

    if([template isEqualToString:@"empty-cell"]) // TODO: these need to come from somewhere
    {
        NBCell * cell = [[NBCell alloc] init];
        cell.type = NBCellSnippet;
        [notebook addCell:cell];
    }

    [[self undoManager] enableUndoRegistration];
}

- (BOOL)hasKeyCell
{
    return ([self keyCellView] != nil);
}

- (BOOL)hasSelectedCell
{
    return ([self selectedCellViews] && ([[self selectedCellViews] count] > 0));
}

- (BOOL)keyCellIsRichText
{
    NBCellView * cellView = [self keyCellView];

    if(cellView)
    {
        return [cellView isRichText];
    }
    else
    {
        return NO;
    }
}

- (IBAction)doSomethingButton:(id)sender
{
    NSLog(@"something");
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
    [[NSApp delegate] setCurrentDocument:self];
}

#pragma mark Selection

- (NBCellView *)keyCellView
{
    NSResponder * firstResponder = [[NSApp keyWindow] firstResponder];

    if([firstResponder conformsToProtocol:@protocol(NBCellSubview)])
    {
        return [(id<NBCellSubview>)firstResponder parentCellView];
    }

    return nil;
}

- (NSArray *)selectedCellViews
{
    NSArray * selectedViews = notebookView.selectedCellViews;

    if([selectedViews count])
    {
        NSMutableArray * orderedSelectedViews = [[NSMutableArray alloc] init];

        // Iterate through in the order that the cells are in the notebook so that
        // they are in display order and not in selection order

        for(NBCell * cell in notebook.cells)
        {
            NBCellView * cellView = [notebookView.cellViews objectForKey:cell];

            if([selectedViews containsObject:cellView])
            {
                [orderedSelectedViews addObject:cellView];
            }
        }

        return orderedSelectedViews;
    }
    else
    {
        NBCellView * currentView = [self keyCellView];

        if(currentView)
        {
            return [NSArray arrayWithObject:currentView];
        }
    }

    return nil;
}

#pragma mark Menu Actions

- (IBAction)increaseIndent:(id)sender
{
    NSResponder * firstResponder = [[NSApp keyWindow] firstResponder];

    if([firstResponder respondsToSelector:@selector(increaseIndent)])
    {
        [firstResponder increaseIndent];
    }
}

- (IBAction)decreaseIndent:(id)sender
{
    NSResponder * firstResponder = [[NSApp keyWindow] firstResponder];

    if([firstResponder respondsToSelector:@selector(decreaseIndent)])
    {
        [firstResponder decreaseIndent];
    }
}

- (IBAction)insertCell:(id)sender
{
    NBCellView * lastSelectedView = [[self selectedCellViews] lastObject];

    NBCell * newCell = [[NBCell alloc] init];
    newCell.type = NBCellSnippet;

    if(lastSelectedView)
    {
        [notebook addCell:newCell afterCell:[lastSelectedView cell]];
    }
    else
    {
        [notebook addCell:newCell];
    }
}

- (IBAction)deleteCell:(id)sender
{
    NSArray * selectedViews = [self selectedCellViews];

    if([selectedViews count])
    {
        for(NBCellView * cellView in selectedViews)
        {
            [notebook removeCell:[cellView cell]];
        }
    }
}

- (IBAction)splitCell:(id)sender
{
    NBCellView * keyView;
    NSRange splitLocation;

    keyView = [self keyCellView];

    if(!keyView)
    {
        return;
    }

    splitLocation = [keyView editableCursorLocation];

    if(splitLocation.location == NSNotFound)
    {
        return;
    }

    [notebook splitCell:[keyView cell] atLocation:splitLocation.location];
}

- (IBAction)mergeCells:(id)sender
{
    NSMutableArray * cells = [[NSMutableArray alloc] init];

    for(NBCellView * cellView in [self selectedCellViews])
    {
        [cells addObject:[cellView cell]];
    }

    [notebook mergeCells:cells];
}

- (IBAction)evaluateCells:(id)sender
{
    for(NBCellView * cellView in [self selectedCellViews])
    {
        [[cellView cell] evaluate];
    }

    NSLog(@"%@", [[notebook engine] globals]);
}

- (IBAction)abortEvaluation:(id)sender
{
    [[notebook engine] abort];
}

- (IBAction)selectAllCells:(id)sender
{
    [notebookView selectAll];
}

- (IBAction)selectAllCellsAboveCurrent:(id)sender
{
    NSArray * selectedViews = [self selectedCellViews];
    NBCellView * startView = [selectedViews objectAtIndex:0];

    if([selectedViews count] != 1)
    {
        return;
    }

    [notebookView deselectAll];

    for(NBCell * cell in notebook.cells)
    {
        NBCellView * cellView = [notebookView.cellViews objectForKey:cell];

        [notebookView selectedCell:cellView];

        if(cellView == startView)
        {
            break;
        }
    }
}

- (IBAction)selectAllCellsBelowCurrent:(id)sender
{
    BOOL sawStartView = NO;
    NSArray * selectedViews = [self selectedCellViews];
    NBCellView * startView = [selectedViews objectAtIndex:0];

    if([selectedViews count] != 1)
    {
        return;
    }

    [notebookView deselectAll];

    for(NBCell * cell in notebook.cells)
    {
        NBCellView * cellView = [notebookView.cellViews objectForKey:cell];

        if(cellView == startView)
        {
            sawStartView = YES;
        }

        if(sawStartView)
        {
            [notebookView selectedCell:cellView];
        }
    }
}

- (IBAction)searchGlobals:(id)sender
{
    NSLog(@"search globals!");
}

@end
