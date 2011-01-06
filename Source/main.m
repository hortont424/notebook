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

#import <Cocoa/Cocoa.h>

#import "NBEngine.h"
#import "NBEngineBackend.h"
#import "NBEngineLoader.h"

#import "NBEngineBackendProtocol.h"

int main(int argc, char *argv[])
{
    NSUserDefaults * args = [NSUserDefaults standardUserDefaults];
    NSString * serverLanguage, * serverPort;

    serverLanguage = [args stringForKey:@"server-language"];
    serverPort = [args stringForKey:@"server-port"];

    if(serverLanguage)
    {
        Class serverClass = [[[NBEngineLoader sharedInstance] engineClasses] objectForKey:serverLanguage];

        NSLog(@"Starting server for %@ on port %@...", serverLanguage, serverPort);

        [[serverClass backendClass] launchServer:serverPort];

        // Tell parent we're ready
        // TODO: this whole signalling mechanism is incredibly dangerous

        kill(getppid(), SIGUSR1);

        /*id<NBEngineBackendProtocol> backend = (id<NBEngineBackendProtocol>)[NSConnection rootProxyForConnectionWithRegisteredName:@"com.hortont.notebook.enginedispatcher" host:nil];

        if(backend == nil)
        {
            NSLog(@"Error: failed to connect to engine dispatcher");
            exit(EXIT_FAILURE);
        }

        NSLog(@"%d", [backend myPid]);*/

        /*NSConnection * connection = [NSConnection new];

        [connection setRootObject:obj];

        if([connection registerName:serverPort] == NO)
        {
            NSLog(@"Couldn't register as %@", serverPort);
            exit(EXIT_FAILURE);
        }*/

        [[NSRunLoop currentRunLoop] run];
    }
    else
    {
        return NSApplicationMain(argc,  (const char **)argv);
    }

    return EXIT_SUCCESS;
}
