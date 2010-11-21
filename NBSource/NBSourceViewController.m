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

#import "NBSourceViewController.h"

@implementation NBSourceViewController

@synthesize parent;

- (void)evaluateSourceView:(id)sourceView
{
    [parent evaluate];
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
    [textStorage addAttribute:NSFontAttributeName value:settings.editorFont range:wholeStringRange];
    
    // First, highlight Python keywords
    
    // TODO: Consider getting the list of keywords from Python (keywords.kwlist), or at least from a file
    NSArray * keywords = [NSArray arrayWithObjects:@"and", @"as", @"assert", @"break", @"class", @"continue", @"def", @"del", @"elif", @"else", @"except", @"exec", @"finally", @"for", @"from", @"global", @"if", @"import", @"in", @"is", @"lambda", @"not", @"or", @"pass", @"print", @"raise", @"return", @"try", @"while", @"with", @"yield", nil];
    
    for(NSString * keyword in keywords)
    {
        [self highlightRegex:[NSString stringWithFormat:@"\\b%@\\b", keyword, nil] onTextStorage:textStorage withHighlight:settings.editorKeywordHighlight];
    }
    
    // Highlight numbers of various formats
    
    [self highlightRegex:@"\\b([1-9]+[0-9]*|0)" onTextStorage:textStorage withHighlight:settings.editorNumberHighlight];
    [self highlightRegex:@"\\b(?i:([1-9]+[0-9]*|0)L)" onTextStorage:textStorage withHighlight:settings.editorNumberHighlight];
    [self highlightRegex:@"\\b(?i:(\\d+e[\\-\\+]?\\d+))" onTextStorage:textStorage withHighlight:settings.editorNumberHighlight];
    [self highlightRegex:@"(?<=[^0-9a-zA-Z_])(?i:(\\.\\d+(e[\\-\\+]?\\d+)?))" onTextStorage:textStorage withHighlight:settings.editorNumberHighlight];
    [self highlightRegex:@"\\b(?i:(\\d+\\.\\d*(e[\\-\\+]?\\d+)?))(?=[^a-zA-Z_])" onTextStorage:textStorage withHighlight:settings.editorNumberHighlight];
    
    // Highlight comments last, as they should take over any other highlighting
    
    [self highlightRegex:@"#.*$" onTextStorage:textStorage withHighlight:settings.editorCommentHighlight];
}

@end
