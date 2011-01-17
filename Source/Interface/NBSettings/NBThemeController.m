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

#import "NBThemeParserController.h"

#import "NBThemeParser.h"
#import "NBThemeParserJSON.h"

static NBThemeParserController * sharedInstance = nil;

@implementation NBThemeParserController

- (id)init
{
    self = [super init];

    if(self != nil)
    {
        themeParsers = [[NSMutableDictionary alloc] init];

        [(NSMutableDictionary *)themeParsers setObject:[NBThemeParserJSON class] forKey:[[NBThemeParserJSON fileExtension] lowercaseString]];
    }

    return self;
}

- (NBThemeParser *)themeParserClassForFilename:(NSString *)filename
{
    NSString * extension = [[filename pathExtension] lowercaseString];

    if(![extension isEqualToString:@""])
    {
        return [themeParsers objectForKey:extension];
    }

    return nil;
}

#pragma mark Singleton Methods

+ (NBThemeParserController *)sharedInstance
{
    @synchronized(self)
    {
        if(sharedInstance == nil)
        {
            sharedInstance = [[NBThemeParserController alloc] init];
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
