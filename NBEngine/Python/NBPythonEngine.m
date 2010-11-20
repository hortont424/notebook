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

#import "NBPythonEngine.h"

@implementation NBPythonEngine

- (id)init
{
    self = [super init];
    
    if(self != nil)
    {
        NSPort * input, * output;
        NSArray * ports;
        
        input = [NSPort port];
        output = [NSPort port];
        ports = [NSArray arrayWithObjects:output, input, nil];
        
        engineConnection = [[NSConnection alloc] initWithReceivePort:input sendPort:output];
        [engineConnection setRootObject:self];
        
        engineThread = nil;
        busy = NO;
        
        [NSThread detachNewThreadSelector:@selector(connectWithPorts:) toTarget:[NBPythonEngineThread class] withObject:ports];
    
        while(!engineThread)
        {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
    }
    
    return self;
}

- (void)setEngineThread:(NSDistantObject<NBPythonEngineThreadProtocol> *)inEngineThread
{
    engineThread = inEngineThread;
    [engineThread setProtocolForProxy:@protocol(NBPythonEngineThreadProtocol)];
}

- (void)executeSnippet:(NSString *)snippet onCompletion:(void (^)(NBException * exception))completion
{
    // TODO: if busy, enqueue snippet!!
    
    busy = YES;
    lastCompletionCallback = [completion copy];
    
    [engineThread executeSnippet:snippet];
}

- (oneway void)snippetComplete:(NBException *)exception
{
    lastCompletionCallback(exception);
    busy = NO;
    lastCompletionCallback = nil;
}

@end
