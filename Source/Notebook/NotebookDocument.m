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

#import "NotebookDocument.h"

#import "NotebookWindowController.h"

@implementation NotebookDocument

@synthesize notebookView;
@synthesize languageButton;
@synthesize splitView;
@synthesize initializedFromFile;

- (id)init
{
    self = [super init];

    if(self != nil)
    {
        initializedFromFile = NO;

        notebook = [[NBNotebook alloc] init];
    }

    return self;
}

- (void)makeWindowControllers
{
    NotebookWindowController * windowController = [[NotebookWindowController alloc] initWithWindowNibName:@"Notebook" owner:self];
    [self addWindowController:windowController];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];

    [notebookView setNotebook:notebook];

    [languageButton setTitle:[[notebookView.notebook.engine class] name]]; // TODO: this should be bound properly
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

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    Class engineClass = [[[NBEngineLoader sharedInstance] engineClasses] objectForKey:typeName];
    NSData * data = nil;

    if(engineClass)
    {
        NBEngineEncoder * encoder = [[[engineClass encoderClass] alloc] init];
        data = [encoder dataForCells:notebook.cells];
    }

    if(outError != NULL)
    {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}

	return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    initializedFromFile = YES;

    Class engineClass = [[[NBEngineLoader sharedInstance] engineClasses] objectForKey:typeName];

    if(engineClass)
    {
        NBEngineEncoder * encoder = [[[engineClass encoderClass] alloc] init];

        [[NSRunLoop mainRunLoop] performSelector:@selector(finishLoadingFile:)
                                          target:self
                                        argument:[NSDictionary dictionaryWithObjectsAndKeys:[encoder cellsFromData:data],@"cells",engineClass,@"engineClass",nil]
                                           order:0
                                           modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
    }

    if(outError != NULL)
    {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}

    return YES;
}

- (void)initDocumentWithEngineClass:(Class)engineClass withTemplate:(NSString *)template
{
    [notebook setEngine:[[engineClass alloc] init]];

    // We need to disable undo registration while creating the cells, otherwise a document will
    // appear as edited immediately after being loaded

    [[self undoManager] disableUndoRegistration];

    if([template isEqualToString:@"empty-cell"]) // TODO: these need to come from somewhere
    {
        NBCell * cell = [[NBCell alloc] init];
        cell.content = @"";
        cell.type = NBCellSnippet;
        [notebook addCell:cell];
    }

    [[self undoManager] enableUndoRegistration];

    [languageButton setTitle:[[notebookView.notebook.engine class] name]];
}

- (IBAction)doSomethingButton:(id)sender
{
    NSLog(@"something");
}

- (IBAction)abortEvaluation:(id)sender
{
    [[notebook engine] abortBackend];
}

@end
