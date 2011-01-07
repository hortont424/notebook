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

#import "NBEngineBackend.h"

#import "NBEngine.h"

@implementation NBEngineBackend

@synthesize engine;

static NSMutableArray * servers = nil;
static NSMutableArray * connections = nil;

+ (void)launchServer:(NSString *)port forClient:(NSString *)clientPort
{
    NBEngineBackend * backend = [[self alloc] init];
    NSConnection * connection = [NSConnection new];

    if(!servers)
    {
        servers = [[NSMutableArray alloc] init];
        connections = [[NSMutableArray alloc] init];
    }

    [servers addObject:backend];
    [connections addObject:connection];

    [connection setRootObject:backend];

    if([connection registerName:port] == NO)
    {
        NSLog(@"Couldn't register engine backend");
        exit(EXIT_FAILURE);
    }

    NSLog(@"Successfully registered engine backend");
}

- (oneway void)executeSnippet:(NSString *)snippet
{
    [self doesNotRecognizeSelector:_cmd];
}

@end
