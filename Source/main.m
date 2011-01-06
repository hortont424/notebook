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

        [[serverClass backendClass] launchServer:serverPort];
    }
    else
    {
        id<NBEngineBackendProtocol> clientObject;
        NSNumber * serverPid;

        clientObject=(id<NBEngineBackendProtocol>)[NSConnection rootProxyForConnectionWithRegisteredName:@"com.hortont.notebook.python.1234567" host:nil];
        [clientObject setProtocolForProxy:@protocol(NBEngineBackendProtocol)];

        if(clientObject==nil)
        {
            NSLog(@"Error: did not get a proxy object for VendingServer service");
            exit(EXIT_FAILURE);
        }
        serverPid=[clientObject myPid];

        if(serverPid!=nil)
        {
            NSLog(@"Remote server on pid %@",serverPid);
        }
        else
        {
            NSLog(@"Error, did not get the server's pid");
            exit(EXIT_FAILURE);
        }

        //return NSApplicationMain(argc,  (const char **)argv);
    }

    return EXIT_SUCCESS;
}
