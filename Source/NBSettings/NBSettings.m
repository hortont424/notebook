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

#import "NBSettings.h"

static NBSettings * sharedInstance = nil;

@implementation NBHighlightSettings

@synthesize font, color;

+ (NBHighlightSettings *)highlightWithColor:(NSColor *)color font:(NSFont *)font
{
    NBHighlightSettings * settings = [[NBHighlightSettings alloc] init];
    
    settings.color = color;
    settings.font = font;
    
    return settings;
}

@end

@implementation NBSettings

@synthesize editorFont, editorBoldFont, editorItalicFont, editorColor;
@synthesize editorCommentHighlight, editorKeywordHighlight, editorNumberHighlight, editorStringHighlight;

@synthesize sourceViewBackgroundColor, outputViewBackgroundColor, commentViewBackgroundColor;
@synthesize statusSuccessColor, statusFailureColor, statusBusyColor, statusDefaultColor;

@synthesize cellAnimationSpeed;
@synthesize cellSpacing;

- (id) init
{
    self = [super init];
    
    if(self != nil)
    {
        editorFont = [NSFont fontWithName:@"Menlo" size:12];
        editorBoldFont = [NSFont fontWithName:@"Menlo Bold" size:12];
        editorItalicFont = [NSFont fontWithName:@"Menlo Italic" size:12];
        editorColor = [NSColor colorWithCalibratedWhite:0.0 alpha:1.0];
        
        highlightSettings = [NSDictionary dictionaryWithObjectsAndKeys:
            [NBHighlightSettings highlightWithColor:[NSColor colorWithCalibratedWhite:0.5 alpha:1.0] font:editorItalicFont], @"comment",
            [NBHighlightSettings highlightWithColor:[NSColor colorWithCalibratedRed:0.306 green:0.604 blue:0.024 alpha:1.0] font:editorBoldFont], @"keyword",
            [NBHighlightSettings highlightWithColor:[NSColor colorWithCalibratedRed:0.125 green:0.290 blue:0.529 alpha:1.0] font:editorFont], @"number",
            [NBHighlightSettings highlightWithColor:[NSColor colorWithCalibratedRed:0.804 green:0.361 blue:0.000 alpha:1.0] font:editorFont], @"string",
            nil];
        
        sourceViewBackgroundColor = [NSColor colorWithCalibratedWhite:1.0 alpha:1.0];
        outputViewBackgroundColor = [NSColor colorWithDeviceWhite:0.9 alpha:1.0];
        commentViewBackgroundColor = [NSColor colorWithDeviceWhite:1.0 alpha:1.0];
        
        statusDefaultColor = [NSColor colorWithCalibratedRed:0.729 green:0.741 blue:0.714 alpha:1.0];
        statusBusyColor = [NSColor colorWithCalibratedRed:0.988 green:0.914 blue:0.310 alpha:1.0];
        statusFailureColor = [NSColor colorWithCalibratedRed:0.788 green:0.000 blue:0.000 alpha:1.0];
        statusSuccessColor = [NSColor colorWithCalibratedRed:0.451 green:0.824 blue:0.086 alpha:1.0];
        
        cellAnimationSpeed = [NSNumber numberWithFloat:0.2];
        cellSpacing = [NSNumber numberWithFloat:4.0];
    }
    
    return self;
}

- (NBHighlightSettings *)highlightForContext:(NSString *)context
{
    return [highlightSettings objectForKey:context];
}

+ (NBSettings *)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
        {    
            sharedInstance = [[NBSettings alloc] init];
        }
    }
    
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
        {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned long)retainCount
{
    return ULONG_MAX;
}

- (void)release
{
}

- (id)autorelease
{
    return self;
}

@end
