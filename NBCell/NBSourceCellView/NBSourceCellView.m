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

#import "NBSourceCellView.h"

#import "NBSourceViewController.h"
#import "NBSettings.h"

@implementation NBSourceCellView

@synthesize sourceView;
@synthesize outputView;
@synthesize controller;
@dynamic delegate;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        NSRect frameWithoutMargin = frame;
        frameWithoutMargin.size.width -= (2 * margin.width);
        frameWithoutMargin.size.height -= (2 * margin.height);
        frameWithoutMargin.origin.x += margin.width;
        frameWithoutMargin.origin.y += margin.height;
    
        controller = [[[NSObjectController alloc] init] autorelease];
        
        NBSourceViewController * sourceViewController = [[NBSourceViewController alloc] init]; // TODO: wrong place
        sourceViewController.parent = self; // TODO: wrong? should be on the view or something
        
        sourceView = [[NBSourceView alloc] initWithFrame:frameWithoutMargin];
        [sourceView setAutoresizingMask:NSViewWidthSizable];
        [sourceView setFieldEditor:NO];
        [sourceView setDelegate:sourceViewController];
        [sourceView setTextContainerInset:NSMakeSize(10, 10)]; // TODO: make it a setting!
        [[sourceView textContainer] setHeightTracksTextView:NO];
        
        outputView = [[NBOutputView alloc] initWithFrame:frameWithoutMargin];
        [outputView setAutoresizingMask:NSViewWidthSizable];
        [outputView setFieldEditor:NO];
        [outputView setDelegate:self];
        [outputView setFont:[[NBSettings sharedInstance] editorFont]];
        [outputView setTextContainerInset:NSMakeSize(10, 10)];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:NSTextDidChangeNotification object:sourceView];
        [self enableContentResizeNotifications];
        
        [self addSubview:sourceView];
    }
    return self;
}

- (BOOL)becomeFirstResponder
{
    // If the NBCellView itself gets focus (someone clicks in the margin), give the contained NBSourceView focus instead
    // It might be better to give the NBOutputView focus if the click is closer to that (TODO?)
    
    [self.window makeFirstResponder:self.sourceView];
    
    return YES;
}

- (void)textViewBecameFirstResponder:(id)textView
{
    // Clear selection in whichever view did *not* just get focus
    
    if(textView == sourceView)
    {
        [outputView setSelectedRange:NSMakeRange(0, 0)];
    }
    else if(textView == outputView)
    {
        [sourceView setSelectedRange:NSMakeRange(0, 0)];
    }
    
    // Clear selection in all the other cells
    
    [delegate cellViewTookFocus:self];
}

- (void)setCell:(NBCell *)inCell
{
    [super setCell:inCell];
    
    [cell addObserver:self forKeyPath:@"output" options:0 context:nil];
    [sourceView setString:cell.content];
    [sourceView display]; // sourceView needs to determine its proper size!
    
    [self subviewDidResize:nil];
}

- (void)evaluate
{
    self.state = NBCellViewEvaluating;
    
    [delegate evaluateCellView:self];
}

- (void)evaluationComplete:(NBException *)exception withOutput:(NSString *)output
{
    // The backend finished evaluating our snippet, so update the NBCell's output string (which will propagate
    // through to the NBOutputView).
    
    if(exception)
    {
        // TODO: highlight line/character where exception occurred
        // TODO: Make error more distinct in the case where we have both (bold it?!)
        cell.output = [NSString stringWithFormat:@"%@", exception.message, nil];
        
        if(output && [output length])
        {
            cell.output = [cell.output stringByAppendingFormat:@"\n\n%@", output, nil];
        }
    }
    else
    {
        if(output && [output length])
        {
            cell.output = [NSString stringWithFormat:@"%@", output, nil];
        }
        else
        {
            cell.output = nil;
        }
    }
    
    self.state = exception ? NBCellViewFailed : NBCellViewSuccessful;
}

- (void)textDidChange:(NSNotification *)aNotification
{
    // Someone typed into the NBSourceView, so our NBCell and evaluation are no longer valid
    
    cell.content = [sourceView string];
    self.state = NBCellViewChanged;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"output"] && (object == cell))
    {
        // Our NBCell's output has changed, so we need to update our NBOutputView to correspond
        
        if(cell.output && ([[self subviews] indexOfObject:outputView] == NSNotFound))
        {
            // There's output now, and there wasn't before: display our NBOutputView
            
            [self addSubview:outputView];
        }
        else if(!cell.output && ([[self subviews] indexOfObject:outputView] != NSNotFound))
        {
            // There's no output now, and there was before: hide our NBOutputView
            
            [outputView removeFromSuperview];
        }
        
        if(cell.output)
        {
            // Update the NBOutputView's displayed string, and force it to redraw so that the size is updated
            
            [outputView setString:cell.output];
            [outputView display];
        }
        
        [self subviewDidResize:nil]; // TODO: this function should probably be renamed/abstracted into two
    }
}

- (void)clearSelection
{
    [sourceView setSelectedRange:NSMakeRange(0, 0)];
    [outputView setSelectedRange:NSMakeRange(0, 0)];
}

@end
