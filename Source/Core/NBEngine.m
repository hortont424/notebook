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

#import "NBEngine.h"

#import <Quartz/Quartz.h>

#import "NBException.h"
#import "NBEngineBackend.h"

@interface NBEngine ()

- (void)backendCrashed:(id)sender;
- (void)launchBackend;
- (void)cleanupBackend:(NSString *)cleanupMessage;

@end

@implementation NBEngine

- (id)init
{
    self = [super init];

    if(self != nil)
    {
        busy = NO;
        taskQueue = [[NSMutableArray alloc] init];
        backend = nil;
        backendTask = nil;

        [self launchBackend];
    }

    return self;
}

- (void)backendCrashed:(id)sender
{
    [self cleanupBackend:@"Backend Crashed."];
}

- (void)launchBackend
{
    NSString * binaryPath = [[[NSProcessInfo processInfo] arguments] objectAtIndex:0];
    NSString * serverLanguage = [[self class] uuid];
    NSString * serverPort = [NSString stringWithFormat:@"com.hortont.notebook.server.%@",[[NSProcessInfo processInfo] globallyUniqueString],nil];

    backendTask = [NSTask launchedTaskWithLaunchPath:binaryPath arguments:[NSArray arrayWithObjects:@"-server-language",serverLanguage,@"-server-port",serverPort,nil]];
    backend = nil;
    busy = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backendCrashed:) name:NSTaskDidTerminateNotification object:backendTask];

    // TODO: This should be done on a different thread and spaced out over time (or just in a timer here!)

    while(!backend && [backendTask isRunning])
    {
        backend = (NBEngineBackend *)[NSConnection rootProxyForConnectionWithRegisteredName:serverPort host:nil];
    }

    if(backend)
    {
        [backend setEngine:self];
    }
    else
    {
        // TODO: better errors
        NSLog(@"Failed to launch backend.");
    }
}

- (void)cleanupBackend:(NSString *)cleanupMessage
{
    NBException * abortException = [[NBException alloc] init];
    abortException.message = cleanupMessage;

    if(backendTask)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:backendTask];

    backend = nil;
    backendTask = nil;

    if(lastCompletionCallback)
        lastCompletionCallback(abortException, nil);

    lastCompletionCallback = nil;

    for(NSDictionary * task in taskQueue)
    {
        SnippetCompletionCallback cb = [task objectForKey:@"callback"];

        cb(abortException, nil);
    }

    [taskQueue removeAllObjects];
}

- (void)abort
{
    if(backendTask && [backendTask isRunning])
        [backendTask terminate];

    [self cleanupBackend:@"Aborted"];
}

#pragma mark Abstract Base Methods

+ (Class)encoderClass
{
    [self doesNotRecognizeSelector:_cmd];

    return nil;
}

+ (Class)backendClass
{
    [self doesNotRecognizeSelector:_cmd];

    return nil;
}

+ (Class)highlighterClass
{
    [self doesNotRecognizeSelector:_cmd];

    return nil;
}

+ (Class)documentClass
{
    [self doesNotRecognizeSelector:_cmd];

    return nil;
}

+ (NSString *)uuid
{
    [self doesNotRecognizeSelector:_cmd];

    return nil;
}

+ (NSString *)name
{
    [self doesNotRecognizeSelector:_cmd];

    return nil;
}

+ (NSString *)version
{
    [self doesNotRecognizeSelector:_cmd];

    return nil;
}

+ (NSImage *)icon
{
    [self doesNotRecognizeSelector:_cmd];

    return nil;
}

// TODO: it seems weird to have the IKImageBrowser stuff in NBCore

#pragma mark IKImageBrowser-related Methods

+ (NSString *)imageTitle
{
    return [self name];
}

+ (NSString *)imageSubtitle
{
    return [NSString stringWithFormat:@"Version %@", [self version]];
}

+ (NSString *)imageRepresentationType
{
    return IKImageBrowserNSImageRepresentationType;
}

+ (id)imageRepresentation
{
    return [self icon];
}

+ (id)imageUID
{
    return [self class];
}

#pragma mark Snippet Evaluation

- (void)executeSnippet:(NSString *)snippet onCompletion:(SnippetCompletionCallback)completion
{
    // If the backend process has died or was never started, try to launch it

    if(!backendTask || ![backendTask isRunning])
    {
        [self launchBackend];
    }

    if(!backend)
    {
        NSLog(@"No backend! Cannot execute snippet"); // TODO: better errors
    }

    // If we're currently in the middle of evaluation, queue up the snippet

    if(busy)
    {
        [taskQueue insertObject:[NSDictionary dictionaryWithObjectsAndKeys:snippet,@"snippet",[completion copy],@"callback",nil] atIndex:0];

        return;
    }

    // Otherwise, execute the current snippet

    busy = YES;
    lastCompletionCallback = [completion copy];
    [backend executeSnippet:snippet];
}

- (oneway void)snippetComplete:(NBException *)exception withOutput:(NSString *)outputString
{
    lastCompletionCallback(exception, outputString);

    busy = NO;
    lastCompletionCallback = nil;

    // If there is another snippet on the queue, dequeue and evaluate it

    if([taskQueue count])
    {
        NSDictionary * enqueuedTask = [taskQueue lastObject];
        [taskQueue removeLastObject];

        [self executeSnippet:[enqueuedTask objectForKey:@"snippet"] onCompletion:[enqueuedTask objectForKey:@"callback"]];
    }
}

@end
