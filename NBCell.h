//
//  NBCell.h
//  Notebook
//
//  Created by Tim Horton on 2010.11.17.
//  Copyright 2010 Rensselaer Polytechnic Institute. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NBCell : NSObject
{
    NSString * content;
}

@property (nonatomic,retain) NSString * content;

@end
