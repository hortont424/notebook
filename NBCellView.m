//
//  NBCellView.m
//  Notebook
//
//  Created by Tim Horton on 2010.11.17.
//  Copyright 2010 Rensselaer Polytechnic Institute. All rights reserved.
//

#import "NBCellView.h"

@implementation NBCellView

@synthesize cell;
@synthesize textView;
@synthesize parent;
@synthesize controller;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        controller = [[[NBCellController alloc] init] autorelease];
        
        textView = [[NSTextView alloc] initWithFrame:frame];
        [textView setFieldEditor:NO];
        [textView setFont:[NSFont fontWithName:@"PanicSans" size:12]];
        [textView setTextContainerInset:NSMakeSize(10, 10)];
        [textView setPostsFrameChangedNotifications:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewResized:) name:NSViewFrameDidChangeNotification object:textView];
        
        [self addSubview:textView];
        
        [controller bind:@"contentObject" toObject:self withKeyPath:@"cell" options:nil];
        [textView bind:@"string" toObject:controller withKeyPath:@"selection.content" options:nil];

        [self textViewResized:nil];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetRGBFillColor(ctx, 1.0, 0.0, 0.0, 1.0);
    CGContextFillRect(ctx, [self bounds]);
}

- (float)requestedHeight
{
    return [textView bounds].size.height + 2;
}

- (void)textViewResized:(NSNotification *)aNotification
{
    NSRect frame = NSZeroRect;
    
    [textView setAutoresizingMask:0];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:textView];
    [parent relayoutViews];
    
    frame.size.width = [self frame].size.width;
    frame.size.height = [self frame].size.height;
    [textView setFrame:NSInsetRect(frame, 1, 1)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewResized:) name:NSViewFrameDidChangeNotification object:textView];
}

@end
