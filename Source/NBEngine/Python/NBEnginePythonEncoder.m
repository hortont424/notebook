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

#import "NBEnginePythonEncoder.h"

#import "NBCell.h"

@implementation NBEnginePythonEncoder

- (NSData *)dataForCells:(NSArray *)cells
{
    NSMutableString * string = [[NSMutableString alloc] init];

    for(NBCell * cell in cells)
    {
        [string appendString:cell.content];

        if(cell != [cells lastObject])
            [string appendString:@"\n\n#--\n\n"];
    }

    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSArray *)cellsFromData:(NSData *)data
{
    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSArray * cellStrings = [string componentsSeparatedByString:@"#--"];
    NSMutableArray * cells = [[NSMutableArray alloc] init];

    for(NSString * cellString in cellStrings)
    {
        NBCell * cell;

        cellString = [cellString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if([cellString isEqualToString:@""])
            continue;

        cell = [[NBCell alloc] init];
        cell.content = cellString;
        cell.type = NBCellSnippet;

        [cells addObject:cell];
    }

    return cells;
}

@end
