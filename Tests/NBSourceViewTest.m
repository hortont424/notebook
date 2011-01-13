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

#import <SenTestingKit/SenTestingKit.h>
#import <NBUI/NBUI.h>

@interface NBSourceViewTest : SenTestCase
{

}

- (void)testInsertNewline;

@end

@implementation NBSourceViewTest

- (void)testInsertNewline
{
    NBSourceView * sourceView = [[NBSourceView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];

    [sourceView setString:@""];
    [sourceView insertNewline:self];

    STAssertEqualObjects([sourceView string], @"\n", @"Insert newline with empty string failed.");

    [sourceView setString:@"asdf"];
    [sourceView insertNewline:self];

    STAssertEqualObjects([sourceView string], @"asdf\n", @"Insert newline with single line string failed.");

    [sourceView setString:@"asdf\n"];
    [sourceView insertNewline:self];

    STAssertEqualObjects([sourceView string], @"asdf\n\n", @"Insert newline with single line string and newline failed.");

    [sourceView setString:@"asdf\n    "];
    [sourceView insertNewline:self];

    STAssertEqualObjects([sourceView string], @"asdf\n    \n    ", @"Insert newline with indentation failed.");

    [sourceView setString:@"\n\n\n"];
    [sourceView insertNewline:self];

    STAssertEqualObjects([sourceView string], @"\n\n\n\n", @"Insert newline with multiple newlines failed.");

    [sourceView setString:@"asdf\n    \n"];
    [sourceView setSelectedRange:NSMakeRange(4,0)];
    [sourceView insertNewline:self];

    STAssertEqualObjects([sourceView string], @"asdf\n\n    \n", @"Insert newline in middle of content failed.");
}

@end
