//
//  NBCellView.h
//  Notebook
//
//  Created by Tim Horton on 2010.11.17.
//  Copyright 2010 Rensselaer Polytechnic Institute. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "NBCell.h"

@class NBNotebookView; // TODO: wrong, need a protocol

@interface NBCellView : NSView<NSTextViewDelegate>
{
    NSTextView * textView;
    NBCell * cell;
    NBNotebookView * parent;
}

@property (assign) NSTextView * textView;
@property (assign) NBNotebookView * parent;
@property (nonatomic,retain) NBCell * cell;

- (void)textDidChange:(NSNotification *)aNotification;
- (float)requestedHeight;
- (void)textViewResized:(NSNotification *)aNotification;

@end
