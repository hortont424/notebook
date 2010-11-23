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

#import "NBEngine.h"

#import "NBEnginePythonBackend.h"

@implementation NBException

@synthesize line, column, message;

@end

@implementation NBEngine

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
        
        taskQueue = [[NSMutableArray alloc] init];
        
        engineConnection = [[NSConnection alloc] initWithReceivePort:input sendPort:output];
        [engineConnection setRootObject:self];
        
        backend = nil;
        busy = NO;
        
        [NSThread detachNewThreadSelector:@selector(connectWithPorts:) toTarget:[self getBackendClass] withObject:ports];
        
        while(!backend)
        {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
    }
    
    return self;
}

- (Class)getBackendClass
{
    [self doesNotRecognizeSelector:_cmd];
    
    return nil;
}

- (Class)getHighlighterClass
{
    [self doesNotRecognizeSelector:_cmd];
    
    return nil;
}

- (void)setBackend:(NBEngineBackend *)inBackend
{
    backend = inBackend;
}

- (void)executeSnippet:(NSString *)snippet onCompletion:(void (^)(NBException * exception, NSString * output))completion
{
    if(busy)
    {
        [taskQueue insertObject:[NSDictionary dictionaryWithObjectsAndKeys:snippet,@"snippet",[completion copy],@"callback",nil] atIndex:0];
        
        return;
    }
    
    busy = YES;
    lastCompletionCallback = [completion copy];
    
    [backend executeSnippet:snippet];
}

- (oneway void)snippetComplete:(NBException *)exception withOutput:(NSString *)outputString
{
    lastCompletionCallback(exception, outputString);
    
    busy = NO;
    lastCompletionCallback = nil;
    
    if([taskQueue count])
    {
        NSDictionary * enqueuedTask = [taskQueue lastObject];
        [taskQueue removeLastObject];
        
        [self executeSnippet:[enqueuedTask objectForKey:@"snippet"] onCompletion:[enqueuedTask objectForKey:@"callback"]];
    }
}

@end