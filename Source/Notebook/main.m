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
#import <NBCore/NBCore.h>
#import <sysexits.h>

int main(int argc, char *argv[])
{
    NSUserDefaults * args = [NSUserDefaults standardUserDefaults];
    NSString * serverLanguage, * serverPort;

    serverLanguage = [args stringForKey:@"server-language"];
    serverPort = [args stringForKey:@"server-port"];

    if(serverLanguage && serverPort)
    {
        Class serverClass = [[[NBEngineLoader sharedInstance] engineClasses] objectForKey:serverLanguage];

        if(serverClass)
        {
            NSLog(@"Starting server for %@ on port %@...", serverLanguage, serverPort);

            [NSThread detachNewThreadSelector:@selector(start) toTarget:[NBProcessWatchdog class] withObject:nil];

            [[serverClass backendClass] launchServer:serverPort];
        }
        else
        {
            NSLog(@"Unknown language %@.", serverLanguage);

            return EXIT_FAILURE;
        }

    }
    else if(serverLanguage || serverPort)
    {
        NSLog(@"Usage: %@ -server-lanuage LANGUAGE -server-port PORT", [[[NSProcessInfo processInfo] arguments] objectAtIndex:0]);

        return EX_USAGE;
    }
    else
    {
        return NSApplicationMain(argc,  (const char **)argv);
    }

    return EXIT_SUCCESS;
}
