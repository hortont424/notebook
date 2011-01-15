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

#import "NBCell.h"
#import "NBEngine.h"
#import "NBNotebook.h"

@interface NBCell ()

- (void)evaluationComplete:(NBException *)exception withOutput:(NSString *)outputString;

@end


@implementation NBCell

@synthesize content, output, exception, type, state;
@synthesize notebook;

- (id)init
{
    self = [super init];

    if(self != nil)
    {
        content = @"";
        output = @"";
    }

    return self;
}

- (void)setContent:(NSString *)aContent
{
    if(![content isEqualToString:aContent])
    {
        [[[notebook delegate] undoManager] registerUndoWithTarget:self
                                                         selector:@selector(setContent:)
                                                           object:[content copy]];
        [[[notebook delegate] undoManager] setActionName:@"Edit Cell"];

        content = [aContent copy];

        self.state = NBCellChangedState;
    }
}

- (void)evaluate
{
    self.state = NBCellBusyState;
    self.output = nil;

    [[notebook engine] executeSnippet:content onCompletion:^(NBException * newException, NSString * outputString) {
        [self evaluationComplete:newException withOutput:outputString];
    }];
}

- (void)evaluationComplete:(NBException *)newException withOutput:(NSString *)outputString
{
    // The backend finished evaluating our snippet, so update our output string.

    self.state = newException ? NBCellFailureState : NBCellSuccessState;
    self.exception = newException;

    if(newException)
    {
        // TODO: Make error more distinct in the case where we have both (bold it?!)
        // TODO: the way the exception is merged into the message is display-side stuff and shouldn't be here

        self.output = [NSString stringWithFormat:@"%@", newException.message, nil];

        if(outputString && [outputString length])
        {
            self.output = [self.output stringByAppendingFormat:@"\n\n%@", outputString, nil];
        }
    }
    else
    {
        if(outputString && [outputString length])
        {
            self.output = [NSString stringWithFormat:@"%@", outputString, nil];
        }
        else
        {
            self.output = nil;
        }
    }
}

@end
