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

#import "NBSourceView.h"

#import <Carbon/Carbon.h>
#import <RegexKit/RegexKit.h>

#import "NBSettings.h"
#import "NBEngineHighlighter.h"
#import "NBNotebook.h"

@implementation NBSourceView

@dynamic delegate;

- (id)initWithFrame:(NSRect)frame	 	
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        [self setBackgroundColor:[[NBSettings sharedInstance] colorWithSelector:@"background.source"]];
    }

    return self;
}

- (void)keyDown:(NSEvent *)theEvent
{
    BOOL handled = NO;
    
    switch([theEvent keyCode])
    {
        case kVK_Return:
            if([theEvent modifierFlags] & NSShiftKeyMask)
            {
                [(id<NBSourceViewDelegate>)delegate evaluate];
                handled = YES;
            }
            break;
    }
    
    if(!handled)
    {
        [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
    }
}

- (void)highlightRegex:(NSString *)regex onTextStorage:(NSTextStorage *)textStorage withHighlight:(NBHighlightSettings *)highlight
{
    RKRegex * expression = [RKRegex regexWithRegexString:regex options:RKCompileMultiline];
    NSString * string = [[textStorage string] stringByAppendingString:@"\n"];
    RKEnumerator * enumerator = [string matchEnumeratorWithRegex:expression];
    
    while([enumerator nextRanges] != NULL)
    {
        NSRange range = [enumerator currentRange];
        
        [textStorage addAttribute:NSForegroundColorAttributeName value:highlight.color range:range];
        [textStorage addAttribute:NSFontAttributeName value:highlight.font range:range];
    }
}

- (void)textStorageDidProcessEditing:(NSNotification *)notification
{
    NSTextStorage * textStorage = [notification object];
    NBSettings * settings = [NBSettings sharedInstance];
    NSRange wholeStringRange = NSMakeRange(0, [[textStorage string] length]);
    
    [textStorage removeAttribute:NSForegroundColorAttributeName range:wholeStringRange];
    [textStorage removeAttribute:NSFontAttributeName range:wholeStringRange];
    [textStorage addAttribute:NSFontAttributeName value:[settings fontWithSelector:@"normal"] range:wholeStringRange];
    [textStorage addAttribute:NSForegroundColorAttributeName value:[settings colorWithSelector:@"normal"] range:wholeStringRange];
    
    NBEngineHighlighter * highlighter = [[[[[[[(id<NBSourceViewDelegate>)delegate cell] notebook] engine] class] highlighterClass] alloc] init];
    
    for(NBEngineHighlightContext * context in [highlighter highlightingPairs])
    {
        [self highlightRegex:context.expression onTextStorage:textStorage withHighlight:[settings highlightWithSelector:context.highlight]];
    }
}

@end
