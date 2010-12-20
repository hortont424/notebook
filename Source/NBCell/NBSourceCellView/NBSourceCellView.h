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

#import <Cocoa/Cocoa.h>

#import "NBCell.h"
#import "NBCellView.h"
#import "NBSourceCellViewDelegate.h"
#import "NBSourceView.h"
#import "NBOutputView.h"
#import "NBEngine.h"

@interface NBSourceCellView : NBCellView<NSTextViewDelegate,NBSourceViewDelegate>
{
    NBSourceView * sourceView;
    NSTextView * outputView;
    NSObjectController * controller; // TODO: pretty sure this is wrong
}

@property (assign) NBSourceView * sourceView;
@property (assign) NSTextView * outputView;
@property (nonatomic,retain) NSObjectController * controller;
@property (nonatomic,retain) id<NBSourceCellViewDelegate> delegate;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

- (void)subviewBecameFirstResponder:(id)subview;

- (void)evaluate;
- (void)evaluationComplete:(NBException *)exception withOutput:(NSString *)output;

@end
