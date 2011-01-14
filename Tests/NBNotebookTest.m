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
#import <NBCore/NBCore.h>

@interface NBNotebookTest : SenTestCase
{

}

- (void)testAddCell;

@end

@implementation NBNotebookTest

- (void)testAddCell
{
    NBNotebook * nb = [[NBNotebook alloc] init];

    NBCell * cell1 = [[NBCell alloc] init];
    NBCell * cell2 = [[NBCell alloc] init];
    NBCell * cell3 = [[NBCell alloc] init];
    NBCell * cell4 = [[NBCell alloc] init];
    NBCell * cell5 = [[NBCell alloc] init];
    NBCell * cell6 = [[NBCell alloc] init];

    [nb addCell:cell1];
    [nb addCell:cell3 afterCell:cell1];
    [nb addCell:cell2 atIndex:1];
    [nb addCell:cell4 afterCell:nil];
    [nb addCell:cell6];
    [nb addCell:cell5 afterCell:cell4];

    NSArray * expected = [NSArray arrayWithObjects:cell1,cell2,cell3,cell4,cell5,cell6,nil];

    STAssertEqualObjects([nb cells], expected, @"addCell variants failed");
}

@end
