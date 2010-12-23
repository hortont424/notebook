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

@implementation NotebookDocument

@synthesize notebookView;
@synthesize languageButton;

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Notebook";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];

    /*NBCreateNotebookView * newNotebook = [[NBCreateNotebookView alloc] init];
    [NSBundle loadNibNamed:@"NBCreateNotebookView" owner:newNotebook];

    [NSApp beginSheet:newNotebook.window modalForWindow:[aController window] modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];*/

    NBCell * cell;
    NBNotebook * notebook = [[NBNotebook alloc] init];
    Class engineClass = [[[NBEngineLoader sharedInstance] engineClasses] lastObject];

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

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}

@end
