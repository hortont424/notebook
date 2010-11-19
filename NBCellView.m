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

#import "NBCellView.h"

@implementation NBCellView

@synthesize cell;
@synthesize sourceView;
@synthesize parent;
@synthesize controller;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        controller = [[[NBCellController alloc] init] autorelease];
        
        sourceView = [[NBSourceView alloc] initWithFrame:frame];
        [sourceView setFieldEditor:NO];
        [sourceView setFont:[NSFont fontWithName:@"Menlo" size:12]];
        [sourceView setTextContainerInset:NSMakeSize(10, 10)];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sourceViewDidResize:) name:NSViewFrameDidChangeNotification object:sourceView];
        
        [self addSubview:sourceView];
        
        [controller bind:@"contentObject" toObject:self withKeyPath:@"cell" options:nil];
        [sourceView bind:@"string" toObject:controller withKeyPath:@"selection.content" options:nil];

        [self sourceViewDidResize:nil];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 0.2);
    CGContextFillRect(ctx, [self bounds]);
}

- (float)requestedHeight
{
    return [sourceView bounds].size.height + 2;
}

- (void)sourceViewDidResize:(NSNotification *)aNotification
{
    NSRect frame = NSZeroRect;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:sourceView];
    
    [parent relayoutViews];
    
    frame.size.width = [self frame].size.width;
    frame.size.height = [self frame].size.height;
    [sourceView setFrame:NSInsetRect(frame, 0, 1)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sourceViewDidResize:) name:NSViewFrameDidChangeNotification object:sourceView];
}

@end
