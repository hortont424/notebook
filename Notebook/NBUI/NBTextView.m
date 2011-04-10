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

/*
 * increaseIndent, decreaseIndent, keyDown
 *
 * Copyright (c) 2010-2011, Rasmus Andersson. All rights reserved.
 *
 * Use of this source code is governed by a MIT-style license that can be
 * found in the Kod section of License.md.
 */

#import "NBTextView.h"

#import <NBSettings/NBSettings.h>

@implementation NBTextView

@synthesize parentCellView, indentString;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];

    if(self)
    {
        leadingSpacesRegex = [RKRegex regexWithRegexString:@"^([[:blank:]]*)" options:RKCompileNoOptions];

        [[self textStorage] setDelegate:self];
        [self setTextContainerInset:NSMakeSize(10, 10)]; // TODO: make it a setting!
        [self setTextColor:[[NBSettingsController sharedInstance] colorWithKey:@"normal"]];
        [self setFont:[[NBSettingsController sharedInstance] fontWithKey:@"normal"]];

        NSMutableParagraphStyle * para = [[NSMutableParagraphStyle alloc] init];
        [para setLineSpacing:2.0];
        [self setDefaultParagraphStyle:para];
        [self setAllowsUndo:NO];

        CFRetain([[NSNotificationCenter defaultCenter] addObserverForName:NBThemeChangedNotification
                                                                   object:nil
                                                                    queue:nil
                                                               usingBlock:^(NSNotification *arg1)
        {
            [self setTextColor:[[NBSettingsController sharedInstance] colorWithKey:@"normal"]];
            [self setFont:[[NBSettingsController sharedInstance] fontWithKey:@"normal"]];
        }]);
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

- (NSString *)indentString
{
    NBSettingsController * settings = [NBSettingsController sharedInstance];
    NSUInteger tabWidth = [settings tabWidth];
    char tabChar = [settings tabCharacter];
    char * tabString;

    if(tabChar == '\t')
    {
        tabWidth = 1;
    }

    tabString = (char *)calloc(tabWidth + 1, sizeof(char));
    memset(tabString, tabChar, tabWidth);

    // TODO: cache this and invalidate when the setting changes

    return [NSString stringWithUTF8String:tabString];
}

- (void)insertNewline:(id)sender
{
    if([[NBSettingsController sharedInstance] shouldMatchIndent])
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

- (void)keyDown:(NSEvent *)event
{
    unsigned short keyCode = event.keyCode;

    if(keyCode == kVK_Tab)
    {
        NSUInteger modifiers = [event modifierFlags];

        if(modifiers & NSAlternateKeyMask)
        {
            // When pressing Alt-TAB, insert regular tab character

            [super keyDown:event];
        }
        else if(modifiers & (NSShiftKeyMask | NSAlphaShiftKeyMask))
        {
            [self decreaseIndent];
        }
        else
        {
            [self increaseIndent];
        }
    }
    else
    {
        [super keyDown:event];
    }
}

- (void)increaseIndent
{
    // Make a copy of the selection before we insert text

    NSRange initialSelectedRange = [self selectedRange];
    NSString * indentationString = [self indentString];
    NSUInteger indentLength = indentationString.length;
    NSRange finalSelectedRange = initialSelectedRange;
    NSString * text = self.textStorage.string;

    if(initialSelectedRange.length == 0)
    {
        // Append |indentationString_| to the start of the current line

        NSUInteger lineStartIndex = [text lineStartForRange:initialSelectedRange];


        // Find whitespace sequence at the start of the line

        NSRange whitespacePrefixRange = [text rangeOfWhitespaceStringAtBeginningOfLineForRange:initialSelectedRange substring:NULL];

        if(whitespacePrefixRange.location != NSNotFound)
        {
            // Adjust indent length if there are uneven number of virtual indentations

            NSUInteger reminder = whitespacePrefixRange.length % indentLength;

            if(reminder)
            {
                indentLength -= reminder;
                indentationString = [indentationString substringToIndex:indentLength];
            }
        }

        // Insert indentation string

        [self setSelectedRange:NSMakeRange(lineStartIndex, 0)];
        [self insertText:indentationString];
        finalSelectedRange.location += indentLength;
    }
    else
    {
        // Expand the effective range to span whole lines

        NSRange effectiveRange = [text lineRangeForRange:initialSelectedRange];

        unichar * srcbuf = [text copyOfCharactersInRange:effectiveRange];
        __block NSUInteger dstlen = 0;
        __block NSUInteger dstCapacity = 0;
        __block unichar* dstbuf = NULL;
        __block NSUInteger lineCount = 0;

        [NSString kodEnumerateLinesOfCharacters:srcbuf
                                       ofLength:effectiveRange.length
                                      withBlock:^(NSRange lineRange)
        {
            // Assure we have enough space in dstbuf to hold the new string

            NSUInteger requiredCapacity = dstlen + indentLength + lineRange.length + 1;

            if(dstCapacity < requiredCapacity)
            {
                dstCapacity = requiredCapacity + (lineCount * indentLength);
                dstbuf = (unichar*)realloc(dstbuf, dstCapacity * sizeof(unichar));
            }

            // Copy indentation string to dstbuf

            [indentationString getCharacters:(dstbuf + dstlen)
                                       range:NSMakeRange(0, indentLength)];
            dstlen += indentLength;

            // Copy source characters to dstbuf

            memcpy((void*)(dstbuf + dstlen), (const void*)(srcbuf + lineRange.location),
                   sizeof(unichar) * lineRange.length);
            dstlen += lineRange.length;

            ++lineCount;
        }];

        // Make replacement string

        NSString * replacementString = [[[NSString alloc] initWithCharactersNoCopy:dstbuf
                                                                            length:dstlen
                                                                      freeWhenDone:YES] autorelease];

        dstbuf = NULL;
        free(srcbuf);
        srcbuf = NULL;

        [self setSelectedRange:effectiveRange];
        [self insertText:replacementString];

        // Adjust new selection range

        finalSelectedRange.location += indentLength;
        finalSelectedRange.length += (dstlen - effectiveRange.length) - indentLength;
    }

    // Adjust selection

    [self setSelectedRange:finalSelectedRange];
}


- (void)decreaseIndent
{
    NSString * indentationString = [self indentString];
    NSUInteger indentLength = indentationString.length;

    // Make a copy of the selection before we insert text

    NSRange initialSelectedRange = [self selectedRange];

    // Reference to the text

    NSString * text = self.textStorage.string;

    // Find selected line(s) boundary

    NSUInteger lineStart = 0, lineEnd = 0, lineEnd2 = 0;
    [text getLineStart:&lineStart end:&lineEnd contentsEnd:NULL forRange:initialSelectedRange];
    [text getLineStart:NULL end:&lineEnd2 contentsEnd:NULL forRange:NSMakeRange(initialSelectedRange.location, 0)];
    NSRange lineRange = NSMakeRange(lineStart, lineEnd-lineStart);

    if(lineEnd2 == lineEnd)
    {
        // This is not a multiline selection, so we take an easier code path

        // Find whitespace sequence at the start of the line

        NSRange whitespacePrefixRange = [text rangeOfWhitespaceStringAtBeginningOfLineForRange:initialSelectedRange];

        if(whitespacePrefixRange.location != NSNotFound)
        {
            // Adjust indent length if there are uneven number of virtual indentations

            NSUInteger reminder = whitespacePrefixRange.length % indentLength;

            if(reminder)
            {
                indentLength = reminder;
            }

            // Remove a chunk of whitespace

            indentLength = MIN(whitespacePrefixRange.length, indentLength);

            if(indentLength != 0)
            {
                NSRange prefixRange = NSMakeRange(whitespacePrefixRange.location, indentLength);

                [self setSelectedRange:prefixRange];
                [self insertText:@""];
                initialSelectedRange.location -= prefixRange.length;
                [self setSelectedRange:initialSelectedRange];
            }
        }
    }
    else
    {
        // Multiline selection

        unichar * srcbuf = [text copyOfCharactersInRange:lineRange];
        __block unichar * dstbuf = (unichar *)malloc(lineRange.length * sizeof(unichar));
        __block NSUInteger dstlen = 0;
        __block NSUInteger charactersRemovedFirstLine = NSNotFound;

        [NSString kodEnumerateLinesOfCharacters:srcbuf
                                       ofLength:lineRange.length
                                      withBlock:^(NSRange lineRange)
        {
            // Advance past whitespace

            NSUInteger i = lineRange.location;
            NSUInteger end = MIN(lineRange.location + lineRange.length,
            lineRange.location + indentLength);

            for(; i < end; ++i)
            {
                unichar ch = srcbuf[i];

                if(ch != ' ' && ch != '\t')
                {
                    break;
                }
            }

            // Record char count

            if(charactersRemovedFirstLine == NSNotFound)
            {
                charactersRemovedFirstLine = (i - lineRange.location);
            }

            // Transfer rest of the characters to dstbuf

            NSUInteger remainingCount = lineRange.length - (i - lineRange.location);
            memcpy((void*)(dstbuf + dstlen), (const void*)(srcbuf + i), sizeof(unichar) * remainingCount);

            dstlen += remainingCount;
        }];

        NSString * replacementString = [[[NSString alloc] initWithCharactersNoCopy:dstbuf
                                                                            length:dstlen
                                                                      freeWhenDone:YES] autorelease];
        dstbuf = NULL;
        free(srcbuf);
        srcbuf = NULL;

        [self setSelectedRange:lineRange];
        [self insertText:replacementString];

        // Restore selection

        if(charactersRemovedFirstLine != NSNotFound)
        {
            NSRange finalSelectedRange = initialSelectedRange;
            NSUInteger charactersRemovedOtherLines = (lineRange.length - dstlen) - charactersRemovedFirstLine;

            finalSelectedRange.location -= charactersRemovedFirstLine;
            finalSelectedRange.length -= charactersRemovedOtherLines;

            [self setSelectedRange:finalSelectedRange];
        }
    }
}

@end
