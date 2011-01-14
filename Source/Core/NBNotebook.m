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

#pragma mark Add/Remove Cells

- (void)addCell:(NBCell *)cell atIndex:(NSUInteger)index
{
    cell.notebook = self;
    [cells insertObject:cell atIndex:index];

    [delegate cellAdded:cell atIndex:index];

    [[delegate undoManager] registerUndoWithTarget:self selector:@selector(removeCell:) object:cell];
    [[delegate undoManager] setActionName:NSLocalizedString(@"Add Cell", @"add-cell")]; // TODO: mark all strings for translation
}

- (void)addCell:(NBCell *)cell afterCell:(NBCell *)afterCell
{
    NSInteger idx = [cells indexOfObject:afterCell];

    if(idx == NSNotFound)
    {
        [self addCell:cell];
    }
    else
    {
        [self addCell:cell atIndex:idx + 1];
    }
}

- (void)addCell:(NBCell *)cell
{
    [self addCell:cell atIndex:[cells count]];
}

- (void)removeCell:(NBCell *)cell
{
    uint index = [cells indexOfObject:cell];

    cell.notebook = nil;
    [cells removeObject:cell];

    [delegate cellRemoved:cell];

    [[[delegate undoManager] prepareWithInvocationTarget:self] addCell:cell atIndex:index];
    [[delegate undoManager] setActionName:NSLocalizedString(@"Remove Cell", @"remove-cell")];
}

#pragma mark Split/Merge Cells

- (void)splitCell:(NBCell *)firstCell atLocation:(NSInteger)splitLocation
{
    [self splitCell:firstCell atLocations:[NSArray arrayWithObject:[NSNumber numberWithInt:splitLocation]]];
}

- (void)splitCell:(NBCell *)firstCell atLocations:(NSArray *)locations
{
    NSMutableArray * allCells = [[NSMutableArray alloc] init];
    NSString * originalContent = [firstCell.content copy];
    NSInteger currentLocation = 0;
    NBCell * currentCell = firstCell;
    NBCell * previousCell = nil;

    // If we don't have any locations, there's no splitting to perform

    if([locations count] == 0)
    {
        return;
    }

    // Merge all undoable operations into one big group

    [[delegate undoManager] beginUndoGrouping];

    // At each split index, make a new cell (unless it's the first one) and split the string up

    for(NSNumber * splitLocation in locations)
    {
        if(previousCell)
        {
            currentCell = [[NBCell alloc] init];
        }

        // Clear the cell's output, assign its content to its portion of the string, and copy the cell type

        currentCell.output = nil;
        currentCell.content = [originalContent substringWithRange:NSMakeRange(currentLocation, [splitLocation intValue])];
        currentCell.type = firstCell.type;

        [allCells addObject:currentCell];

        if(previousCell)
        {
            [self addCell:currentCell afterCell:previousCell];
        }

        currentLocation += [splitLocation intValue];
        previousCell = currentCell;
    }

    // Add the last one
    // TODO: this fails dry

    currentCell = [[NBCell alloc] init];
    currentCell.output = nil;
    currentCell.content = [originalContent substringWithRange:NSMakeRange(currentLocation, [originalContent length] - currentLocation)];
    currentCell.type = firstCell.type;
    [allCells addObject:currentCell];
    [self addCell:currentCell afterCell:previousCell];

    [[delegate undoManager] endUndoGrouping];
    [[delegate undoManager] setActionName:NSLocalizedString(@"Split Cell", @"split-cell")];
}

- (void)mergeCells:(NSArray *)cellList
{
    NSMutableString * entireString = [[NSMutableString alloc] init];
    NSMutableArray * mergeLocations = [[NSMutableArray alloc] init];
    NBCellType mergeType = NBCellNone;
    NBCell * firstCell = nil;
    NSInteger currentLength = 0;

    [[delegate undoManager] beginUndoGrouping];

    // There's nothing to merge if we have less than two cells

    if([cellList count] < 2)
    {
        return;
    }

    // Combine the contents of all of the selected cells, keeping track of where we are when we merge them in case
    // we need to re-split them

    // Note: We iterate through NBNotebook's list of cells instead of the cellList array so that we
    // will combine them in the correct order

    for(NBCell * cell in cells)
    {
        if([cellList containsObject:cell])
        {
            // If this is the first cell, save the type, and only accept cells of this type later
            // TODO: there's no reason we can't support merging comment and code cells, but that's going
            // to require more intelligence

            if(mergeType == NBCellNone)
            {
                mergeType = cell.type;
                firstCell = cell;
            }
            else if(cell.type != mergeType)
            {
                continue;
            }

            [entireString appendString:cell.content];
            currentLength += [cell.content length];
            [mergeLocations addObject:[NSNumber numberWithInt:currentLength]];
        }
    }

    if(!firstCell)
    {
        NSLog(@"Selected cells not found in notebook"); // TODO: better errors
        return;
    }

    // Pop off the last location, as it's the end of the string, not technically a split location

    [mergeLocations removeLastObject];

    // Remove all but the first cell (which is the one we're going to put all of the content into)

    for(NBCell * cell in cellList)
    {
        if(cell != firstCell)
        {
            [self removeCell:cell];
        }
    }

    firstCell.output = nil;
    firstCell.content = entireString;

    [[delegate undoManager] endUndoGrouping];
    [[delegate undoManager] setActionName:NSLocalizedString(@"Merge Cells", @"merge-cells")];
}

@end
