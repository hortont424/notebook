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

#import <Cocoa/Cocoa.h>

#define NBThemeChangedNotification @"NBThemeChangedNotification"
#define NBTabWidthChangedNotification @"NBTabWidthChangedNotification"
#define NBMatchIndentChangedNotification @"NBMatchIndentChangedNotification"
#define NBPairCharactersChangedNotification @"NBPairCharactersChangedNotification"
#define NBWrapLinesChangedNotification @"NBWrapLinesChangedNotification"
#define NBTabInsertTypeChangedNotification @"NBTabInsertTypeChangedNotification"
#define NBCreateUntitledModeChangedNotification @"NBCreateUntitledModeChangedNotification"
#define NBHighlightSyntaxChangedNotification @"NBHighlightSyntaxChangedNotification"
#define NBHighlightGlobalsChangedNotification @"NBHighlightGlobalsChangedNotification"
#define NBFontNameChangedNotification @"NBFontNameChangedNotification"

#define NBThemeNameKey @"theme"
#define NBTabWidthKey @"tabWidth"
#define NBMatchIndentKey @"formatMatchIndent"
#define NBPairCharactersKey @"formatPairCharacters"
#define NBWrapLinesKey @"layoutWrapLines"
#define NBTabInsertTypeKey @"tabType"
#define NBCreateUntitledModeKey @"createUntitledMode"
#define NBHighlightSyntaxKey @"highlightSyntax"
#define NBHighlightGlobalsKey @"highlightGlobals"
#define NBFontNameKey @"fontName"

#define NBThemeNameDefault @"Tango"
#define NBTabWidthDefault 4
#define NBMatchIndentDefault YES
#define NBPairCharactersDefault NO
#define NBWrapLinesDefault YES
#define NBTabInsertTypeDefault 1
#define NBCreateUntitledModeDefault 0
#define NBHighlightSyntaxDefault YES
#define NBHighlightGlobalsDefault YES
#define NBFontNameDefault @""

@class NBHighlightSettings;
@class NBTheme;

@interface NBSettings : NSObject
{
    NSMutableDictionary * themes;
}

@property (readonly) NSString * themeName;
@property (nonatomic,assign) NSMutableDictionary * themes;

+ (NBSettings *)sharedInstance;

- (void)loadThemes:(NSArray *)paths;

- (NSString *)themeName;
- (NSUInteger)tabWidth;
- (BOOL)shouldMatchIndent;
- (BOOL)shouldHighlightGlobals;
- (BOOL)shouldPairCharacters;
- (BOOL)shouldWrapLines;
- (char)tabCharacter;
- (NSUInteger)createUntitledMode;
- (BOOL)shouldHighlightSyntax;
- (BOOL)shouldHighlightGlobals;

- (NSColor *)colorWithKey:(NSString *)key;
- (NSFont *)fontWithKey:(NSString *)key;
- (NBHighlightSettings *)highlightWithKey:(NSString *)key;
- (NSObject *)settingWithKey:(NSString *)key;

@end
