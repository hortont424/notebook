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

/*
 * All of the regular expressions provided below are distributed under the terms of
 * the MIT license, as obtained from:
 * http://code.google.com/p/ebundles/source/browse/#svn/trunk
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "NBEnginePythonHighlighter.h"

static NBEngineHighlighter * sharedInstance = nil;

@implementation NBEnginePythonHighlighter

- (id)init
{
    self = [super init];

    if(self != nil)
    {
        NSMutableArray * initialPairs = [[NSMutableArray alloc] init];

        // TODO: eventually move these to a file
        // TODO: eventually find a better way to do this all, this is nonsense

        // First, highlight Python keywords
        // TODO: Consider getting the list of keywords from Python (keywords.kwlist), or at least from a file

        NSArray * keywords = [NSArray arrayWithObjects:@"and", @"as", @"assert", @"break", @"class", @"continue", @"def", @"del", @"elif", @"else", @"except", @"exec", @"finally", @"for", @"from", @"global", @"if", @"import", @"in", @"is", @"lambda", @"not", @"or", @"pass", @"print", @"raise", @"return", @"try", @"while", @"with", @"yield", nil];

        for(NSString * keyword in keywords)
        {
            [initialPairs addObject:[NBEngineHighlightContext contextWithClass:@"keyword" expression:[NSString stringWithFormat:@"\\b%@\\b", keyword, nil]]];
        }

        // Highlight numbers of various formats

        [initialPairs addObject:[NBEngineHighlightContext contextWithClass:@"number" expression:@"\\b([1-9]+[0-9]*|0)"]];
        [initialPairs addObject:[NBEngineHighlightContext contextWithClass:@"number" expression:@"\\b(?i:([1-9]+[0-9]*|0)L)"]];
        [initialPairs addObject:[NBEngineHighlightContext contextWithClass:@"number" expression:@"\\b(?i:(\\d+e[\\-\\+]?\\d+))"]];
        [initialPairs addObject:[NBEngineHighlightContext contextWithClass:@"number" expression:@"(?<=[^0-9a-zA-Z_])(?i:(\\.\\d+(e[\\-\\+]?\\d+)?))"]];
        [initialPairs addObject:[NBEngineHighlightContext contextWithClass:@"number" expression:@"\\b(?i:(\\d+\\.\\d*(e[\\-\\+]?\\d+)?))(?=[^a-zA-Z_])"]];

        // Highlight strings
        // TODO: these should not match cross-line, and the triple-quoted string should
        // TODO: string highlighting doesn't work, it matches stuff in comments (for obvious reasons)

        //[initialPairs addObject:[NBEngineHighlightContext contextWithClass:@"string" expression:@"\"([^\"\\\\]*(\\\\.[^\"\\\\]*)*)\""]];
        //[initialPairs addObject:[NBEngineHighlightContext contextWithClass:@"string" expression:@"\'([^\'\\\\]*(\\\\.[^\'\\\\]*)*)\'"]];

        // Highlight comments last, as they should take over any other highlighting

        [initialPairs addObject:[NBEngineHighlightContext contextWithClass:@"comment" expression:@"#.*$"]];

        highlightingPairs = (NSArray *)initialPairs;
    }

    return self;
}

+ (NBEngineHighlighter *)sharedInstance
{
    @synchronized(self)
    {
        if(sharedInstance == nil)
        {
            sharedInstance = [[NBEnginePythonHighlighter alloc] init];
        }
    }

    return sharedInstance;
}

@end
