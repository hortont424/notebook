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

#import <Cocoa/Cocoa.h>

@interface NBHighlightSettings : NSObject
{
    NSFont * font;
    NSColor * color;
}

@property (nonatomic,assign) NSFont * font;
@property (nonatomic,assign) NSColor * color;

+ (NBHighlightSettings *)highlightWithColor:(NSColor *)color font:(NSFont *)font;

@end

@interface NBSettings : NSObject
{
    NSFont * editorFont, * editorBoldFont, * editorItalicFont;
    NSColor * editorColor;
    
    NBHighlightSettings * editorCommentHighlight, * editorKeywordHighlight, * editorNumberHighlight;
    
    NSColor * sourceViewBackgroundColor, * outputViewBackgroundColor;
    NSColor * statusSuccessColor, * statusFailureColor, * statusBusyColor, * statusDefaultColor;
    
    NSNumber * cellAnimationSpeed;
    NSNumber * cellSpacing;
}

@property (nonatomic,assign) NSFont * editorFont;
@property (nonatomic,assign) NSFont * editorBoldFont;
@property (nonatomic,assign) NSFont * editorItalicFont;
@property (nonatomic,assign) NSColor * editorColor;

@property (nonatomic,assign) NBHighlightSettings * editorCommentHighlight;
@property (nonatomic,assign) NBHighlightSettings * editorKeywordHighlight;
@property (nonatomic,assign) NBHighlightSettings * editorNumberHighlight;

@property (nonatomic,assign) NSColor * sourceViewBackgroundColor;
@property (nonatomic,assign) NSColor * outputViewBackgroundColor;
@property (nonatomic,assign) NSColor * statusSuccessColor;
@property (nonatomic,assign) NSColor * statusFailureColor;
@property (nonatomic,assign) NSColor * statusBusyColor;
@property (nonatomic,assign) NSColor * statusDefaultColor;

@property (nonatomic,assign) NSNumber * cellAnimationSpeed;
@property (nonatomic,assign) NSNumber * cellSpacing;

+ (NBSettings *)sharedInstance;

@end
