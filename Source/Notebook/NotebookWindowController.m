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

#import <Quartz/Quartz.h>

#import "NotebookWindowController.h"

#import "NotebookDocument.h"

@implementation NotebookWindowController

- (void)windowDidLoad
{
    if(![[self document] initializedFromFile])
    {
        createNotebookController = [[NBCreateNotebookView alloc] init];

        [NSBundle loadNibNamed:@"NBCreateNotebookView" owner:createNotebookController];

        createNotebookController.delegate = self;

        [[[self document] splitView] removeFromSuperview];

        NSRect viewBounds = [[createNotebookController mainView] bounds];
        NSRect winFrame = [[self window] frame];

        [[self window] setFrame:NSMakeRect(winFrame.origin.x - ((viewBounds.size.width - winFrame.size.width) / 2.0),
                                           winFrame.origin.y - ((viewBounds.size.height - winFrame.size.height) / 2.0),
                                           viewBounds.size.width,
                                           viewBounds.size.height) display:NO];

        [[self window] setMinSize:NSMakeSize([[self window] frame].size.width, 250)];
        [[self window] setMaxSize:NSMakeSize([[self window] frame].size.width, 800)];

        [[createNotebookController mainView] setFrame:[[[self window] contentView] frame]];
        [[[self window] contentView] addSubview:[createNotebookController mainView]];
    }
    else
    {
        [[self window] setMinSize:NSMakeSize(150, 150)];
        [[self window] setMaxSize:NSMakeSize(10000, 10000)];
    }
}

- (void)createNotebookWithEngineClass:(Class)engineClass
{
    NSRect viewBounds = [[[self document] splitView] bounds];
    NSRect winFrame = [[self window] frame];
    NSRect screenFrame = [[[self window] screen] visibleFrame];

    NSRect newViewFrame = NSMakeRect(winFrame.origin.x - ((viewBounds.size.width - winFrame.size.width) / 2.0),
                                     screenFrame.origin.y + (screenFrame.size.height * 0.1),
                                     viewBounds.size.width,
                                     screenFrame.size.height * 0.8);

    [[self window] setFrame:[[self window] constrainFrameRect:newViewFrame
                                                     toScreen:[[self window] screen]]
                    display:YES
                    animate:YES];


    [[self window] setMinSize:NSMakeSize(150, 150)];
    [[self window] setMaxSize:NSMakeSize(10000, 10000)];

    [[[self document] splitView] setFrame:[[[self window] contentView] frame]];
    [[[self window] contentView] addSubview:[[self document] splitView]
                                 positioned:NSWindowBelow
                                 relativeTo:[createNotebookController mainView]];

    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:0.5f] forKey:kCATransactionAnimationDuration];

    // slide animation
    float ypos = [[createNotebookController mainView] frame].size.height -
                 [[createNotebookController mainView] layer].shadowRadius;
    [[createNotebookController mainView] setFrameOrigin:NSMakePoint(0, ypos)];

    CALayer * layer = [[createNotebookController mainView] layer];
    slideAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    [slideAnimation setFromValue:[NSValue valueWithPoint:NSMakePoint(0, 0)]];
    [slideAnimation setToValue:[NSValue valueWithPoint:NSPointFromCGPoint(layer.position)]];
    [slideAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [slideAnimation setDelegate:self];
    [layer addAnimation:slideAnimation forKey:@"position"];

    [CATransaction commit];

    // If we initialize the document before the view is realized, the cells that are created during initialization
    // will be broken until one resize occurs.

    [[self document] initDocumentWithEngineClass:engineClass withTemplate:@"empty-cell"];
}

- (void)openExistingNotebook
{
    [[self document] close];
    [[NSDocumentController sharedDocumentController] openDocument:self];
}

- (void)cancelCreateNotebook
{
    [[self document] close];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished
{
    [[createNotebookController mainView] removeFromSuperview];
    [[[self document] splitView] setWantsLayer:NO];
    [[[self window] contentView] setWantsLayer:NO];
    createNotebookController = nil;
}

@end
