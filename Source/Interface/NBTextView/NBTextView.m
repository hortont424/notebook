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

#import "NBTextView.h"

#import "NBSettings.h"
#import "NBTheme.h"

@implementation NBTextView

@synthesize parentCellView;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];

    if(self)
    {
        [[self textStorage] setDelegate:self];
        [self setTextContainerInset:NSMakeSize(10, 10)]; // TODO: make it a setting!
        [self setTextColor:[[NBSettings sharedInstance] colorWithKey:@"normal"]];
        [self setFont:[[NBSettings sharedInstance] fontWithKey:@"normal"]];

        NSMutableParagraphStyle * para = [[NSMutableParagraphStyle alloc] init];
        [para setLineSpacing:2.0];
        [self setDefaultParagraphStyle:para];
        [self setAllowsUndo:NO];
    }

    return self;
}

- (BOOL)becomeFirstResponder
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NBCellSubviewBecameFirstResponder" object:self];

    return [super becomeFirstResponder];
}

- (float)requestedHeight
{
    NSLayoutManager * layoutManager = [self layoutManager];
    NSTextContainer * textContainer = [self textContainer];

    [layoutManager glyphRangeForTextContainer:textContainer];

    // TODO: the 20 = 2*10 (the text view inset) and will come from there when that's made a setting

    return [layoutManager usedRectForTextContainer:textContainer].size.height + 20;
}

@end
