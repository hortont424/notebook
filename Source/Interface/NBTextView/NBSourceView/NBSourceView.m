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

#import "NBSourceView.h"

#import <NBCore/NBCore.h>

#import "NBSettings.h"
#import "NBTheme.h"
#import "NBHighlightSettings.h"

@implementation NBSourceView

@synthesize delegate;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];

    if(self)
    {
        exceptions = [[NSMutableDictionary alloc] init];
        leadingSpacesRegex = [RKRegex regexWithRegexString:@"^([[:blank:]]*)" options:RKCompileNoOptions];

        [self setBackgroundColor:[[NBSettings sharedInstance] colorWithKey:@"background.source"]];

        CFRetain([[NSNotificationCenter defaultCenter] addObserverForName:NBThemeChangedNotification
                                                                   object:nil
                                                                    queue:nil
                                                               usingBlock:^(NSNotification * arg1)
        {
            [self setBackgroundColor:[[NBSettings sharedInstance] colorWithKey:@"background.source"]];
        }]);

        void (^rehighlight)(NSNotification * arg1) = CFRetain(^(NSNotification *arg1)
        {
            [self textStorageDidProcessEditing:nil];
        });

        CFRetain([[NSNotificationCenter defaultCenter] addObserverForName:NBHighlightSyntaxChangedNotification
                                                                   object:nil
                                                                    queue:nil
                                                               usingBlock:rehighlight]);

        CFRetain([[NSNotificationCenter defaultCenter] addObserverForName:NBHighlightGlobalsChangedNotification
                                                                   object:nil
                                                                    queue:nil
                                                               usingBlock:rehighlight]);
    }

    return self;
}

- (void)insertNewline:(id)sender
{
    if([[NBSettings sharedInstance] shouldMatchIndent])
    {
        NSRange insertionPoint;
        NSUInteger start, end;
        NSString * lineSubstring, * leadingSpaces;
        NSRange leadingSpacesRange;

        insertionPoint = [[[self selectedRanges] lastObject] rangeValue];

        [[self string] getLineStart:&start end:&end contentsEnd:NULL forRange:insertionPoint];

        lineSubstring = [[self string] substringWithRange:NSMakeRange(start, end - start)];
        leadingSpacesRange = [lineSubstring rangeOfRegex:leadingSpacesRegex];

        if(leadingSpacesRange.location != NSNotFound)
        {
            leadingSpaces = [lineSubstring substringWithRange:leadingSpacesRange];
        }
        else
        {
            leadingSpaces = @"";
        }

        [self insertText:[@"\n" stringByAppendingString:leadingSpaces]];
    }
    else
    {
        [super insertNewline:sender];
    }

}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    // Highlight errors

    if([exceptions count])
    {
        NSLayoutManager * layout = [self layoutManager];
        NBSettings * settings = [NBSettings sharedInstance];
        CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];

        NSUInteger currentLocation = 0, lineNumber = 0;
        NSArray * lines = [[self string] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

        for(NSString * line in lines)
        {
            NSUInteger nextLocation = currentLocation + [line length] + 1;
            NBException * exception;

            lineNumber++;

            if((exception = [exceptions objectForKey:[NSNumber numberWithInt:lineNumber]]))
            {
                NSUInteger fromIndex = [layout glyphIndexForCharacterAtIndex:currentLocation] + exception.column; // TODO: check if column is glyphs or characters

                if(fromIndex == [[self string] length])
                {
                    fromIndex--;
                }

                while([[NSCharacterSet newlineCharacterSet] characterIsMember:[[self string] characterAtIndex:[layout characterIndexForGlyphAtIndex:fromIndex]]] && fromIndex >= 0)
                {
                    fromIndex--;
                }

                NSRect bounds = [layout boundingRectForGlyphRange:NSMakeRange(fromIndex, 1) inTextContainer:[self textContainer]];
                bounds.origin.x += [self textContainerOrigin].x;
                bounds.origin.y += [self textContainerOrigin].y;

                CGContextMoveToPoint(ctx, bounds.origin.x, bounds.origin.y + bounds.size.height);
                CGContextAddLineToPoint(ctx, bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height);
                CGContextAddLineToPoint(ctx, bounds.origin.x + (bounds.size.width / 2), bounds.origin.y + bounds.size.height - 3);
                CGContextClosePath(ctx);

                [[settings colorWithKey:@"status.failure"] setFill]; // TODO: this should get its own selector

                CGContextFillPath(ctx);
            }

            currentLocation = nextLocation;
        }
    }
}

- (void)addException:(NBException *)exception
{
    [exceptions setObject:exception forKey:[NSNumber numberWithInt:exception.line]];

    [self setNeedsDisplay:YES];
}

- (void)clearExceptions
{
    [exceptions removeAllObjects];

    [self setNeedsDisplay:YES];
}

- (void)highlightRegex:(RKRegex *)expression onTextStorage:(NSTextStorage *)textStorage withHighlight:(NBHighlightSettings *)highlight
{
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
    NSTextStorage * textStorage = [self textStorage];
    NBSettings * settings = [NBSettings sharedInstance];
    NSRange wholeStringRange = NSMakeRange(0, [[textStorage string] length]);

    // Remove all attributes, then reapply the defaults

    [textStorage removeAttribute:NSForegroundColorAttributeName range:wholeStringRange];
    [textStorage removeAttribute:NSFontAttributeName range:wholeStringRange];
    [textStorage removeAttribute:NSUnderlineStyleAttributeName range:wholeStringRange];
    [textStorage removeAttribute:NSUnderlineColorAttributeName range:wholeStringRange];
    [textStorage addAttribute:NSFontAttributeName value:[settings fontWithKey:@"normal"] range:wholeStringRange];
    [textStorage addAttribute:NSForegroundColorAttributeName value:[settings colorWithKey:@"normal"] range:wholeStringRange];

    if([[NBSettings sharedInstance] shouldHighlightSyntax])
    {
        // Apply each syntax highlighting style

        NBEngineHighlighter * highlighter = [[[[[[(id<NBSourceViewDelegate>)delegate cell] notebook] engine] class] highlighterClass] sharedInstance];

        for(NBEngineHighlightContext * context in [highlighter highlightingPairs])
        {
            [self highlightRegex:context.expression onTextStorage:textStorage withHighlight:[settings highlightWithKey:context.highlight]];
        }
    }
}

@end
