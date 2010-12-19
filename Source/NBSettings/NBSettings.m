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

#import <JSON/JSON.h>

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

- (id)init
{
    self = [super init];
    
    if(self != nil)
    {
        NSArray * themes = [[NSBundle mainBundle] pathsForResourcesOfType:nil inDirectory:@"Themes"];
        NSString * themeFilename = [themes lastObject];
        NSString * themeString = [NSString stringWithContentsOfFile:themeFilename encoding:NSUTF8StringEncoding error:nil];
        NSError * jsonError = nil;

        NSDictionary * theme = [[[SBJsonParser alloc] init] objectWithString:themeString error:&jsonError];
        NSDictionary * themePart;
        
        if(jsonError)
        {
            NSLog(@"%@", jsonError);
        }
        
        fonts = [[NSMutableDictionary alloc] init];
        colors = [[NSMutableDictionary alloc] init];
        highlights = [[NSMutableDictionary alloc] init];
        settings = [[NSMutableDictionary alloc] init];
        
        themePart = [theme objectForKey:@"fonts"];
        
        for(NSString * fontType in themePart)
        {
            NSDictionary * fontDict = [themePart objectForKey:fontType];
            [fonts setObject:[NSFont fontWithName:[fontDict objectForKey:@"name"] size:[[fontDict objectForKey:@"size"] floatValue]] forKey:fontType];
        }
        
        themePart = [theme objectForKey:@"colors"];
        
        for(NSString * colorType in themePart)
        {
            NSDictionary * colorDict = [themePart objectForKey:colorType];
            [colors setObject:[NSColor colorWithCalibratedRed:[[colorDict objectForKey:@"r"] floatValue]
                                                        green:[[colorDict objectForKey:@"g"] floatValue]
                                                         blue:[[colorDict objectForKey:@"b"] floatValue]
                                                        alpha:[[colorDict objectForKey:@"a"] floatValue]] forKey:colorType];
        }
        
        themePart = [theme objectForKey:@"highlights"];
        
        for(NSString * highlightType in themePart)
        {
            NSDictionary * highlightDict = [themePart objectForKey:highlightType];
            [highlights setObject:[NBHighlightSettings highlightWithColor:[self colorWithSelector:[highlightDict objectForKey:@"color"]]
                                                                     font:[self fontWithSelector:[highlightDict objectForKey:@"font"]]] forKey:highlightType];
        }
    }
    
    return self;
}

- (NSFont *)fontWithSelector:(NSString *)sel
{
    NSFont * font = [fonts objectForKey:sel];
    
    if(!font)
    {
        NSLog(@"Unknown font selector %@!", sel);
        
        font = [fonts objectForKey:@"normal"];
        
        if(!font)
        {
            font = [NSFont systemFontOfSize:12.0];
        }
    }
    
    return font;
}

- (NSColor *)colorWithSelector:(NSString *)sel
{
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
