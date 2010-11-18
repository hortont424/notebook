//
//  NBNotebook.m
//  Notebook
//
//  Created by Tim Horton on 2010.11.17.
//  Copyright 2010 Rensselaer Polytechnic Institute. All rights reserved.
//

#import "NBNotebook.h"

@implementation NBNotebook

- (id) init
{
    self = [super init];
    
    if(self != nil)
    {
        cells = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)addCell:(NBCell *)cell
{
    [cells addObject:cell];
}

@end
