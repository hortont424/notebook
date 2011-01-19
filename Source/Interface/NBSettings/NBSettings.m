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

#import "NBSettings.h"

#import <JSON/JSON.h>

#import "NBHighlightSettings.h"
#import "NBTheme.h"

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

static NBSettings * sharedInstance = nil;

@implementation NBSettings

@synthesize themeName, themes;

- (id)init
{
    // TODO: protect all singleton inits from reinit

    self = [super init];

    if(self != nil)
    {
        themes = nil;

        // Set up global defaults

        NSMutableDictionary * appDefaults = [[NSMutableDictionary alloc] init];

        [appDefaults setObject:NBThemeNameDefault forKey:NBThemeNameKey];

        [appDefaults setObject:NBThemeNameDefault forKey:NBThemeNameKey];
        [appDefaults setObject:[NSNumber numberWithInt:NBTabWidthDefault] forKey:NBTabWidthKey];
        [appDefaults setObject:[NSNumber numberWithBool:NBMatchIndentDefault] forKey:NBMatchIndentKey];
        [appDefaults setObject:[NSNumber numberWithBool:NBPairCharactersDefault] forKey:NBPairCharactersKey];
        [appDefaults setObject:[NSNumber numberWithBool:NBWrapLinesDefault] forKey:NBWrapLinesKey];
        [appDefaults setObject:[NSNumber numberWithInt:NBTabInsertTypeDefault] forKey:NBTabInsertTypeKey];
        [appDefaults setObject:[NSNumber numberWithInt:NBCreateUntitledModeDefault] forKey:NBCreateUntitledModeKey];
        [appDefaults setObject:[NSNumber numberWithBool:NBHighlightSyntaxDefault] forKey:NBHighlightSyntaxKey];
        [appDefaults setObject:[NSNumber numberWithBool:NBHighlightGlobalsDefault] forKey:NBHighlightGlobalsKey];
        [appDefaults setObject:NBFontNameDefault forKey:NBFontNameKey];

        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    }

    return self;
}

- (void)loadThemes:(NSArray *)paths
{
    if(themes)
    {
        NSLog(@"themes have already been loaded");
    }

    themes = [[NSMutableDictionary alloc] init];

    // Load all of the given themes

    for(NSString * themeFilename in paths)
    {
        NBTheme * parsedTheme = [NBTheme themeWithFile:themeFilename];

        if(parsedTheme)
        {
            [themes setObject:parsedTheme forKey:[parsedTheme name]];
        }
    }

    if(![themes objectForKey:self.themeName])
    {
        NSLog(@"Failed to load theme %@", self.themeName);

        self.themeName = NBThemeNameDefault;

        if(![themes objectForKey:NBThemeNameDefault])
        {
            NSLog(@"Failed to load default theme!");
        }
    }
}

- (void)setThemeName:(NSString *)inThemeName
{
    [[NSUserDefaults standardUserDefaults] setObject:inThemeName forKey:NBThemeNameKey];

    [[NSNotificationCenter defaultCenter] postNotificationName:NBThemeChangedNotification object:self];
}

- (NSString *)themeName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:NBThemeNameKey];
}

#pragma mark Setting Accessors

- (NSColor *)colorWithKey:(NSString *)key
{
    return [[themes objectForKey:self.themeName] colorWithKey:key];
}

- (NSFont *)fontWithKey:(NSString *)key
{
    return [[themes objectForKey:self.themeName] fontWithKey:key];
}

- (NBHighlightSettings *)highlightWithKey:(NSString *)key
{
    return [[themes objectForKey:self.themeName] highlightWithKey:key];
}

- (NSObject *)settingWithKey:(NSString *)key
{
    return [[themes objectForKey:self.themeName] settingWithKey:key];
}

#pragma mark Singleton Methods

+ (NBSettings *)sharedInstance
{
    @synchronized(self)
    {
        if(sharedInstance == nil)
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
        if(sharedInstance == nil)
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
