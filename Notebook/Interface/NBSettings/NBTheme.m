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

#import "NBTheme.h"

#import "NBHighlightSettings.h"

#import "NBThemeJSON.h"

static NSMutableDictionary * themeParsers;

@implementation NBTheme

@synthesize filename;
@synthesize name, author, version;
@synthesize colors, fonts, highlights, settings;

+ (void)initialize
{
    [super initialize];

    themeParsers = [[NSMutableDictionary alloc] init];
    [themeParsers setObject:[NBThemeJSON class] forKey:[[NBThemeJSON fileExtension] lowercaseString]];
}

- (id)initWithFile:(NSString *)aFilename
{
    [self doesNotRecognizeSelector:_cmd];

    return nil;
}

+ (id)themeWithFile:(NSString *)aFilename
{
    Class parserClass;
    NSString * extension = [[aFilename pathExtension] lowercaseString];

    if(![extension isEqualToString:@""])
    {
        parserClass = [themeParsers objectForKey:extension];

        return [[parserClass alloc] initWithFile:aFilename];
    }

    return nil;
}

+ (NSString *)fileExtension
{
    [self doesNotRecognizeSelector:_cmd];

    return nil;
}

- (NSColor *)colorWithKey:(NSString *)key
{
    return [colors colorWithKey:key];
}

- (NSFont *)fontWithKey:(NSString *)key
{
    return [fonts objectForKey:key];
}

- (NBHighlightSettings *)highlightWithKey:(NSString *)key
{
    return [highlights objectForKey:key];
}

- (NSObject *)settingWithKey:(NSString *)key
{
    return [settings objectForKey:key];
}

@end
