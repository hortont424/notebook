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

#import "NBThemeJSON.h"

#import <JSON/JSON.h>

#import "NBHighlightSettings.h"
#import "NSColor+Notebook.h"

@implementation NBThemeJSON

- (id)initWithFile:(NSString *)aFilename
{
    self = [super init];

    if(self != nil)
    {
        NSString * themeString;
        NSError * jsonError = nil;
        NSDictionary * themeObject;

        filename = aFilename;

        // Load theme from given JSON file, parse into Objective-C objects

        themeString = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:nil];
        themeObject = [[[SBJsonParser alloc] init] objectWithString:themeString error:&jsonError];

        if(jsonError)
        {
            // TODO: show proper error message in UI

            NSLog(@"%@", jsonError);
            return nil;
        }

        // Load metadata

        name = [themeObject objectForKey:@"name"];
        author = [themeObject objectForKey:@"author"];
        version = [themeObject objectForKey:@"version"];

        // Load colors

        colors = [[NSColorList alloc] initWithName:@""];

        [[themeObject objectForKey:@"colors"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
        {
            NSColor * color = [NSColor colorFromObject:obj];

            if(color)
            {
                [colors setColor:color forKey:key];
            }
            else
            {
                NSLog(@"Failed to parse color: %@ %@", key, obj);
            }
        }];

        // Load fonts

        fonts = [[NSMutableDictionary alloc] init];

        [[themeObject objectForKey:@"fonts"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             NSFont * font;

             font = [NSFont fontWithName:[obj objectForKey:@"name"] size:[[obj objectForKey:@"size"] floatValue]];

             if(font)
             {
                 [(NSMutableDictionary *)fonts setObject:font forKey:key];
             }
             else
             {
                 NSLog(@"Failed to parse font: %@ %@", key, obj);
             }
         }];

        // Load highlights

        highlights = [[NSMutableDictionary alloc] init];

        [[themeObject objectForKey:@"highlights"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
        {
            NBHighlightSettings * highlight;

            highlight = [NBHighlightSettings highlightWithColor:[self colorWithKey:[obj objectForKey:@"color"]]
                                                           font:[self fontWithKey:[obj objectForKey:@"font"]]];

            if(highlight)
            {
                [(NSMutableDictionary *)highlights setObject:highlight forKey:key];
            }
            else
            {
                NSLog(@"Failed to parse highlight: %@ %@", key, obj);
            }
        }];

        // Load other settings

        settings = [[NSMutableDictionary alloc] init];

        [[themeObject objectForKey:@"settings"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
        {
            [(NSMutableDictionary *)settings setObject:obj forKey:key];
        }];
    }

    return self;
}

+ (NSString *)fileExtension
{
    return @"js";
}

@end
