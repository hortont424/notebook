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

#import "NotebookAppDelegate.h"

@interface NotebookAppDelegate ()

- (void)loadThemes;
- (void)currentDocumentInitializedChanged;

@end

@implementation NotebookAppDelegate

@synthesize languageMenuItem;
@synthesize currentDocument;

- (void)loadThemes
{
    [[NBSettingsController sharedInstance] loadThemes:[[NSBundle mainBundle] pathsForResourcesOfType:nil inDirectory:@"Themes"]];
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    [self loadThemes];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    settingsWindowController = [[NBSettingsWindowController alloc] initWithWindowNibName:@"NBSettingsWindow"];
}

- (IBAction)showPreferences:(id)sender
{
    [settingsWindowController showWindow:self];
}

- (void)setCurrentDocument:(NotebookDocument *)inDocument
{
    currentDocument = inDocument;

    [currentDocument addObserver:self forKeyPath:@"initialized" options:0 context:nil];

    [self currentDocumentInitializedChanged];
}

- (void)currentDocumentInitializedChanged
{
    if([currentDocument initialized])
    {
        [[languageMenuItem submenu] setTitle:[[[[currentDocument notebook] engine] class] name]];
        [languageMenuItem setHidden:NO];
    }
    else
    {
        [languageMenuItem setHidden:YES];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"initialized"] && (object == currentDocument))
    {
        [self currentDocumentInitializedChanged];
    }
}

@end
