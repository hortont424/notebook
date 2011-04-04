/*
 * Copyright 2011 Matthew Arsenault. All rights reserved.
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
 * THIS SOFTWARE IS PROVIDED BY MATTHEW ARSENAULT "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
 * SHALL MATTHEW ARSENAULT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NBEngineLua.h"

#import <LuaFramework/lua.h>

#import "NBEngineLuaBackend.h"
#import "NBEngineLuaHighlighter.h"
#import "NBEngineLuaEncoder.h"
#import "NBEngineLuaDocument.h"

@implementation NBEngineLua

+ (Class)backendClass
{
    return [NBEngineLuaBackend class];
}

+ (Class)highlighterClass
{
    return [NBEngineLuaHighlighter class];
}

+ (Class)encoderClass
{
    return [NBEngineLuaEncoder class];
}

+ (Class)documentClass
{
    return [NBEngineLuaDocument class];
}

+ (NSString*) uuid
{
    return @"com.hortont.notebook.lua";
}

+ (NSString*) name
{
    return @"Lua";
}

+ (NSString*) version
{
    return [[[NSString stringWithUTF8String:LUA_RELEASE] componentsSeparatedByString:@" "] objectAtIndex:0];
}

+ (NSImage*) icon
{
    return [[NSImage alloc] initByReferencingFile:[[NSBundle bundleForClass:self] pathForImageResource:@"lua.png"]];
}

@end
