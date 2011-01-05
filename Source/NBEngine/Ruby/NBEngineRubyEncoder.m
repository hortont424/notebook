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

#import "NBEngineRubyEncoder.h"

#import "NBCell.h"

@implementation NBEngineRubyEncoder

- (NSData *)dataForCells:(NSArray *)cells
{
    NSMutableString * string = [[NSMutableString alloc] init];

    // Concatenate the contents of each cell into one big string to write to the file

    for(NBCell * cell in cells)
    {
        [string appendString:cell.content];

        // Add a marker between all cells

        if(cell != [cells lastObject])
            [string appendString:@"\n\n#--\n\n"]; // TODO: this should probably be semi-adjustable (but then would
                                                  // need to be encoded in the file, for portability)
    }

    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSArray *)cellsFromData:(NSData *)data
{
    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // Split the file into sections delimited by the cell-division comment, stripping trailing whitespace and newlines

    NSArray * cellStrings = [string componentsSeparatedByString:@"#--"]; // TODO: this will currently match anywhere (?)
    NSMutableArray * cells = [[NSMutableArray alloc] init];

    // Create a cell for each section

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
