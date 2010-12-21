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

@synthesize connection, engine;

+ (void)connectWithPorts:(NSArray *)ports
{
    NSAutoreleasePool * pool;
    NSConnection * classConnection;
    NBEngineBackend * backend;

    pool = [[NSAutoreleasePool alloc] init];
    classConnection = [NSConnection connectionWithReceivePort:[ports objectAtIndex:0] sendPort:[ports objectAtIndex:1]];
    backend = [[self alloc] init];

    backend.connection = classConnection;
    backend.engine = (NBEngine *)[classConnection rootProxy];

    [backend.engine setBackend:(NBEngineBackend *)backend];

    [[NSRunLoop currentRunLoop] run];

    [pool drain];
}

- (oneway void)executeSnippet:(NSString *)snippet
{
    [self doesNotRecognizeSelector:_cmd];
}

@end
