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

#import <Cocoa/Cocoa.h>

#import "NBNotebookDelegate.h"

@class NBCell;
@class NBEngine;

@interface NBNotebook : NSObject
{
    NSMutableArray * cells;
    NBEngine * engine;

    id<NBNotebookDelegate> delegate;
}

@property (nonatomic,retain) NSMutableArray * cells;
@property (nonatomic,retain) NBEngine * engine;
@property (nonatomic,assign) id<NBNotebookDelegate> delegate;

- (void)addCell:(NBCell *)cell;
- (void)addCell:(NBCell *)cell atIndex:(NSUInteger)index;
- (void)addCell:(NBCell *)cell afterCell:(NBCell *)afterCell;

- (void)removeCell:(NBCell *)cell;

- (void)splitCell:(NBCell *)firstCell atLocation:(NSInteger)splitLocation;
- (void)splitCell:(NBCell *)firstCell atLocations:(NSArray *)locations;

- (void)mergeCells:(NSArray *)cellList;

@end
