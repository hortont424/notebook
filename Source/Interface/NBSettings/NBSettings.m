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

        NSUserDefaultsController * defaultsController = [NSUserDefaultsController sharedUserDefaultsController];

        [defaultsController addObserver:self forKeyPath:[@"values." stringByAppendingString:NBThemeNameKey] options:0 context:nil];
        [defaultsController addObserver:self forKeyPath:[@"values." stringByAppendingString:NBTabWidthKey] options:0 context:nil];
        [defaultsController addObserver:self forKeyPath:[@"values." stringByAppendingString:NBMatchIndentKey] options:0 context:nil];
        [defaultsController addObserver:self forKeyPath:[@"values." stringByAppendingString:NBPairCharactersKey] options:0 context:nil];
        [defaultsController addObserver:self forKeyPath:[@"values." stringByAppendingString:NBWrapLinesKey] options:0 context:nil];
        [defaultsController addObserver:self forKeyPath:[@"values." stringByAppendingString:NBTabInsertTypeKey] options:0 context:nil];
        [defaultsController addObserver:self forKeyPath:[@"values." stringByAppendingString:NBCreateUntitledModeKey] options:0 context:nil];
        [defaultsController addObserver:self forKeyPath:[@"values." stringByAppendingString:NBHighlightSyntaxKey] options:0 context:nil];
        [defaultsController addObserver:self forKeyPath:[@"values." stringByAppendingString:NBHighlightGlobalsKey] options:0 context:nil];
        [defaultsController addObserver:self forKeyPath:[@"values." stringByAppendingString:NBFontNameKey] options:0 context:nil];
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

        [[NSUserDefaults standardUserDefaults] setObject:NBThemeNameDefault forKey:NBThemeNameKey];

        if(![themes objectForKey:NBThemeNameDefault])
        {
            NSLog(@"Failed to load default theme!");
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString * key = [keyPath stringByReplacingOccurrencesOfString:@"values." withString:@""];

    if([key isEqualToString:NBThemeNameKey])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NBThemeChangedNotification object:self];
    }
    else if([key isEqualToString:NBTabWidthKey])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NBTabWidthChangedNotification object:self];
    }
    else if([key isEqualToString:NBMatchIndentKey])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NBMatchIndentChangedNotification object:self];
    }
    else if([key isEqualToString:NBPairCharactersKey])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NBPairCharactersChangedNotification object:self];
    }
    else if([key isEqualToString:NBWrapLinesKey])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NBWrapLinesChangedNotification object:self];
    }
    else if([key isEqualToString:NBTabInsertTypeKey])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NBTabInsertTypeChangedNotification object:self];
    }
    else if([key isEqualToString:NBCreateUntitledModeKey])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NBCreateUntitledModeChangedNotification object:self];
    }
    else if([key isEqualToString:NBHighlightSyntaxKey])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NBHighlightSyntaxChangedNotification object:self];
    }
    else if([key isEqualToString:NBHighlightGlobalsKey])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NBHighlightGlobalsChangedNotification object:self];
    }
    else if([key isEqualToString:NBFontNameKey])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NBFontNameChangedNotification object:self];
    }
}

#pragma mark Setting Accessors

- (NSString *)themeName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:NBThemeNameKey];
}

- (NSUInteger)tabWidth
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:NBTabWidthKey] unsignedIntValue];
}

- (BOOL)shouldMatchIndent
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:NBMatchIndentKey] boolValue];
}

- (BOOL)shouldPairCharacters
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:NBPairCharactersKey] boolValue];
}

- (BOOL)shouldWrapLines
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:NBWrapLinesKey] boolValue];
}

- (char)tabCharacter
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:NBMatchIndentKey] unsignedIntValue] ? '\t' : ' ';
}

- (NBCreateUntitledModes)createUntitledMode
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:NBCreateUntitledModeKey] unsignedIntValue];
}

- (BOOL)shouldHighlightSyntax
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:NBHighlightSyntaxKey] boolValue];
}

- (BOOL)shouldHighlightGlobals
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:NBHighlightGlobalsKey] boolValue];
}

#pragma mark Keyed Setting Accessors

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
