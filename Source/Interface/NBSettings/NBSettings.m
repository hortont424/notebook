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

static NBSettings * sharedInstance = nil;

@implementation NBSettings

- (id)init
{
    // TODO: protect all singleton inits from reinit

    self = [super init];

    if(self != nil)
    {
        themes = nil;
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
        NSDictionary * theme = [self themeFromFile:themeFilename];

        if(theme)
        {
            [themes setObject:theme forKey:[[theme objectForKey:@"settings"] objectForKey:@"name"]];
        }
    }

    // TODO: this should be loaded from a Cocoa defaults file

    currentTheme = @"Tango";

    if([themes objectForKey:currentTheme] == nil)
    {
        NSLog(@"failed to find theme %@", currentTheme);
    }
}

- (NSDictionary *)themeFromFile:(NSString *)filename
{
    NSString * themeString;
    NSError * jsonError = nil;
    NSDictionary * themeObject, * themePart;
    NSMutableDictionary * fonts, * colors, * highlights, * settings, * theme;

    theme = [[NSMutableDictionary alloc] init];

    // Load theme from given JSON file, parse into Objective-C objects

    themeString = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:nil];
    themeObject = [[[SBJsonParser alloc] init] objectWithString:themeString error:&jsonError];

    if(jsonError)
    {
        // TODO: show proper error message in UI

        NSLog(@"%@", jsonError);
        return nil;
    }

    fonts = [[NSMutableDictionary alloc] init];
    colors = [[NSMutableDictionary alloc] init];
    highlights = [[NSMutableDictionary alloc] init];
    settings = [[NSMutableDictionary alloc] init];

    // Load fonts from theme

    themePart = [themeObject objectForKey:@"fonts"];

    for(NSString * fontType in themePart)
    {
        NSDictionary * fontDict = [themePart objectForKey:fontType];

        // Convert font descriptor from JSON (name/size pair) to NSFont

        [fonts setObject:[NSFont fontWithName:[fontDict objectForKey:@"name"] size:[[fontDict objectForKey:@"size"] floatValue]] forKey:fontType];
    }

    [theme setObject:fonts forKey:@"fonts"];

    // Load colors from theme

    themePart = [themeObject objectForKey:@"colors"];

    for(NSString * colorType in themePart)
    {
        id color = [themePart objectForKey:colorType];

        if([color isKindOfClass:[NSDictionary class]])
        {
            NSDictionary * colorDict = color;

            // Convert color descriptor from JSON (rgba dictionary) to NSColor

            [colors setObject:[NSColor colorWithCalibratedRed:[[colorDict objectForKey:@"r"] floatValue]
                                                        green:[[colorDict objectForKey:@"g"] floatValue]
                                                         blue:[[colorDict objectForKey:@"b"] floatValue]
                                                        alpha:[[colorDict objectForKey:@"a"] floatValue]] forKey:colorType];
        }
        else if([color isKindOfClass:[NSString class]])
        {
            NSString * colorName = color;

            [colors setObject:[[NSColorList colorListNamed:@"System"] colorWithKey:colorName] forKey:colorType];
        }
    }

    [theme setObject:colors forKey:@"colors"];

    // Load highlight descriptors from theme (these refer to colors and fonts, so those need to be loaded first)

    themePart = [themeObject objectForKey:@"highlights"];

    for(NSString * highlightType in themePart)
    {
        NSDictionary * highlightDict = [themePart objectForKey:highlightType];

        // Convert highlight descriptor from JSON (reference to font/color) to NBHighlightSettings

        [highlights setObject:[NBHighlightSettings highlightWithColor:[colors objectForKey:[highlightDict objectForKey:@"color"]]
                                                                 font:[fonts objectForKey:[highlightDict objectForKey:@"font"]]] forKey:highlightType];
    }

    [theme setObject:highlights forKey:@"highlights"];

    // Copy all toplevel theme entries we haven't already used into another dictionary of generic parameters

    NSArray * skipThemeParts = [theme allKeys];

    for(NSString * toplevelType in themeObject)
    {
        if([skipThemeParts containsObject:toplevelType])
            continue;

        [settings setObject:[themeObject objectForKey:toplevelType] forKey:toplevelType];
    }

    [theme setObject:settings forKey:@"settings"];

    return theme;
}

- (NSFont *)fontWithSelector:(NSString *)sel
{
    NSDictionary * fonts = [[themes objectForKey:currentTheme] objectForKey:@"fonts"];
    NSFont * font = [fonts objectForKey:sel];

    if(!font)
    {
        NSLog(@"Unknown font selector %@!", sel);

        font = [fonts objectForKey:@"normal"];

        if(!font)
        {
            font = [NSFont fontWithName:@"Courier New" size:12.0];
        }
    }

    return font;
}

- (NSColor *)colorWithSelector:(NSString *)sel
{
    NSDictionary * colors = [[themes objectForKey:currentTheme] objectForKey:@"colors"];
    NSColor * color = [colors objectForKey:sel];

    if(!color)
    {
        NSLog(@"Unknown color selector %@!", sel);

        color = [colors objectForKey:@"normal"];

        if(!color)
        {
            color = [NSColor colorWithDeviceWhite:0.0 alpha:1.0];
        }
    }

    return color;
}

- (NBHighlightSettings *)highlightWithSelector:(NSString *)sel
{
    NSDictionary * highlights = [[themes objectForKey:currentTheme] objectForKey:@"highlights"];
    NBHighlightSettings * highlight = [highlights objectForKey:sel];

    if(!highlight)
    {
        NSLog(@"Unknown highlight selector %@!", sel);

        highlight = [highlights objectForKey:@"normal"];

        if(!highlight)
        {
            highlight = [NBHighlightSettings highlightWithColor:[self colorWithSelector:@"normal"] font:[self fontWithSelector:@"normal"]];
        }
    }

    return highlight;
}

- (id)settingsWithSelector:(NSString *)sel
{
    return [[[themes objectForKey:currentTheme] objectForKey:@"settings"] objectForKey:sel];
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
