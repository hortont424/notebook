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

#import <Quartz/Quartz.h>

#import "NBEngine.h"

@implementation NBException

@synthesize line, column, message;

@end

BOOL serverHasLaunched = NO;

void sigusr1(int dummy)
{
    serverHasLaunched = YES;
}

@implementation NBEngine

- (id)init
{
    self = [super init];

    if(self != nil)
    {
        busy = NO;
        taskQueue = [[NSMutableArray alloc] init];

        const char * binaryPath = [[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] UTF8String];
        const char * serverLanguage = [[[self class] uuid] UTF8String];

        NSLog(@"%s %s", binaryPath, serverLanguage);

        // TODO: CRITICAL: children aren't cleaned up when the parent dies

        sigset_t mask, oldmask;

        sigemptyset (&mask);
        sigaddset (&mask, SIGUSR1);

        signal(SIGUSR1, sigusr1);

        sigprocmask (SIG_BLOCK, &mask, &oldmask);

        serverHasLaunched = NO;

        if(fork() == 0)
        {
            execl(binaryPath, binaryPath, "-server-language", serverLanguage, "-server-port", "com.hortont.notebook.asdf", NULL);

            _exit(0);
        }

        while(!serverHasLaunched)
            sigsuspend(&oldmask);

        sigprocmask (SIG_UNBLOCK, &mask, NULL);

        NSLog(@"hey we got the signal");

        // TODO: instead of launching the server and trying to connect to it, launch the server, wait for it to connect to us
        // on the global com.hortont.notebook object, then do the connection backwards

        backend = (id<NBEngineBackendProtocol>)[NSConnection rootProxyForConnectionWithRegisteredName:@"com.hortont.notebook.asdf" host:nil];

        if(backend == nil)
        {
            NSLog(@"Error: failed to spawn engine backend");
            exit(EXIT_FAILURE);
        }

        NSNumber * serverPid = [backend myPid];

        if(serverPid)
        {
            NSLog(@"Remote server on pid %@",serverPid);
        }
        else
        {
            NSLog(@"Error, did not get the server's pid");
            exit(EXIT_FAILURE);
        }
    }

    return self;
}

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

@end
