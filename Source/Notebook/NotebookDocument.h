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

@interface NotebookDocument : NSDocument
{
    IBOutlet NBNotebookView * notebookView;
    IBOutlet BWAnchoredButton * languageButton;

    IBOutlet BWSplitView * splitView;

    BOOL initialized;
    BOOL initializedFromFile;
    NBNotebook * notebook;
}

@property (nonatomic,assign) NBNotebookView * notebookView;
@property (nonatomic,assign) BWAnchoredButton * languageButton;
@property (nonatomic,assign) BWSplitView * splitView;

@property (nonatomic,assign) BOOL initialized;
@property (nonatomic,assign) BOOL initializedFromFile;
@property (nonatomic,assign) NBNotebook * notebook;

- (void)initDocumentWithEngineClass:(Class)engineClass withTemplate:(NSString *)template;

- (IBAction)doSomethingButton:(id)sender;

- (IBAction)insertCell:(id)sender;
- (IBAction)deleteCell:(id)sender;
- (IBAction)splitCell:(id)sender;
- (IBAction)mergeCells:(id)sender;

- (IBAction)evaluateCells:(id)sender;
- (IBAction)abortEvaluation:(id)sender;

@end
