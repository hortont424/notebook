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

#import "NBCreateNotebookView.h"

#import "NBEngineLoader.h" // TODO: this is obviously wrong, we need to reintroduce the language chooser

#import "NotebookWindowController.h"

@implementation NotebookDocument

@synthesize notebookView;
@synthesize languageButton;
@synthesize splitView;

- (void)makeWindowControllers
{
    NotebookWindowController * windowController = [[NotebookWindowController alloc] initWithWindowNibName:@"Notebook" owner:self];
    [self addWindowController:windowController];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    if(outError != NULL)
    {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}

	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    NSLog(@"%@", typeName);

    if(outError != NULL)
    {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}

    return YES;
}

- (void)initDocumentWithEngineClass:(Class)engineClass
{
    NBCell * cell;
    NBNotebook * notebook = [[NBNotebook alloc] init];

    [notebookView setNotebook:notebook];
    [[notebookView notebook] setEngine:[[engineClass alloc] init]];

    cell = [[NBCell alloc] init];
    cell.content = @"This is a really long comment.\n\nIt can describe what code around it does,\nor how to use something.";
    cell.type = NBCellComment;
    [notebook addCell:cell];

    cell = [[NBCell alloc] init];
    cell.content = @"import random";
    [notebook addCell:cell];

    cell = [[NBCell alloc] init];
    cell.content = @"print [\n\n";
    [notebook addCell:cell];

    cell = [[NBCell alloc] init];
    cell.content = @"def doSomethingRandom(max=5):\n    return random.uniform(0, max)";
    [notebook addCell:cell];

    cell = [[NBCell alloc] init];
    cell.content = @"print doSomethingRandom()";
    [notebook addCell:cell];

    cell = [[NBCell alloc] init];
    cell.content = @"for x in range(1000):\n    print x";
    [notebook addCell:cell];

    cell = [[NBCell alloc] init];
    cell.content = @"asdf = lambda x : x + 2\n\ndef asdf2():\n    print asdf(2), \"some random string\" # 4, definitely\n\nasdf2()";
    [notebook addCell:cell];

    [languageButton setTitle:[[notebookView.notebook.engine class] name]];

    // Queue up a redisplay for the next run through the main loop (by then, the window will be realized)
    // This is a hack (why aren't we redisplaying properly?)

    [notebookView performSelector:@selector(setNeedsDisplay:) withObject:(id)YES afterDelay:0];
}

- (IBAction)doSomethingButton:(id)sender
{
    NSLog(@"something");
}

@end
