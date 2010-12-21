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

#import "NBNotebook.h"

@implementation NBNotebook

@synthesize cells;
@synthesize engine;
@synthesize delegate;

- (id)init
{
    self = [super init];
    
    if(self != nil)
    {
        cells = [[NSMutableArray alloc] init];
        delegate = nil;
    }
    
    return self;
}

- (void)addCell:(NBCell *)cell atIndex:(NSUInteger)index
{
    cell.notebook = self;
    [cells insertObject:cell atIndex:index];
    
    [delegate cellAdded:cell atIndex:index];
}

- (void)addCell:(NBCell *)cell afterCell:(NBCell *)afterCell
{
    [self addCell:cell atIndex:[cells indexOfObject:afterCell] + 1];
}

- (void)addCell:(NBCell *)cell
{
    [self addCell:cell atIndex:[cells count]];
}

- (void)removeCell:(NBCell *)cell
{
    cell.notebook = nil;
    [cells removeObject:cell];
    
    [delegate cellRemoved:cell];
}

@end
