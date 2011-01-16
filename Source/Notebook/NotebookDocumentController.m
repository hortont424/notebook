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

#import "NotebookDocumentController.h"

#import <NBUI/NBUI.h>

#import "NotebookDocument.h"

static NSMutableArray * _documentClassNames = nil;

@implementation NotebookDocumentController

- (NSArray *)documentClassNames
{
    if(_documentClassNames == nil)
    {
        _documentClassNames = [[NSMutableArray alloc] init];

        for(Class engineClass in [[[NBEngineLoader sharedInstance] engineClasses] allValues])
        {
            [_documentClassNames addObject:[[engineClass uuid] copy]];
        }
    }

    return _documentClassNames;
}

- (Class)documentClassForType:(NSString *)documentTypeName
{
    return [NotebookDocument class];
}

// TODO: fileExtensionsFromType: is deprecated, but it's the only way I've found to specify extensions at runtime
// Overriding NSDocument's fileNameExtensionForType:saveOperation: instead doesn't work because it doesn't get called

- (NSArray *)fileExtensionsFromType:(NSString *)documentTypeName
{
    return [NSArray arrayWithObject:[[[[NBEngineLoader sharedInstance] engineClasses] objectForKey:documentTypeName] fileExtension]];
}

- (NSString *)typeFromFileExtension:(NSString *)fileExtension
{
    for(Class engineClass in [[[NBEngineLoader sharedInstance] engineClasses] allValues])
    {
        if([[engineClass fileExtension] isEqualToString:fileExtension])
        {
            return [engineClass uuid];
        }
    }

    return @"Notebook";
}

- (NSString *)displayNameForType:(NSString *)documentTypeName
{
    return [[[[NBEngineLoader sharedInstance] engineClasses] objectForKey:documentTypeName] fileTypeName];
}

@end
