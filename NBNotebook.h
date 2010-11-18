//
//  NBNotebook.h
//  Notebook
//
//  Created by Tim Horton on 2010.11.17.
//  Copyright 2010 Rensselaer Polytechnic Institute. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "NBCell.h"

@interface NBNotebook : NSObject
{
    NSMutableArray * cells;
}

- (void)addCell:(NBCell *)cell;

@end
