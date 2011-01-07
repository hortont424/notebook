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

#import "NBEngineRubyBackend.h"

static NBException * exception;

@implementation NBEngineRubyBackend

- (id)init
{
    self = [super init];

    if (self != nil)
    {
        ruby_init();
        ruby_init_loadpath();

        rb_define_module([[[NSProcessInfo processInfo] globallyUniqueString] UTF8String]);

        rb_require("stringio");
        stringIOModule = rb_const_get(rb_cObject, rb_intern("StringIO"));
    }

    return self;
}

- (VALUE)captureRubyStdout
{
    // Install a StringIO object as $stdout so we can intercept Ruby's output
    // TODO: intercept stderr too!

    VALUE stringIOObject = rb_funcall3(stringIOModule, rb_intern("new"), 0, 0);

    rb_gv_set("$stdout", stringIOObject);

    return stringIOObject;
}

- (NSString *)prepareCapturedRubyStdout:(VALUE)stringIOObject
{
    rb_funcall3(stringIOObject, rb_intern("rewind"), 0, 0);
    VALUE stdoutValue = rb_funcall3(stringIOObject, rb_intern("read"), 0, 0);

    return [NSString stringWithUTF8String:StringValueCStr(stdoutValue)];
}

static VALUE exceptionHandler(VALUE unused)
{
    exception = [[NBException alloc] init];
    exception.message = @"Ruby exception!";

    return Qtrue;
}

static VALUE evaluateString(VALUE ary)
{
    VALUE str = rb_ary_entry(ary, 0);

    rb_eval_string(StringValueCStr(str));

    return Qtrue;
}

- (oneway void)executeSnippet:(NSString *)snippet
{
    VALUE stringIOObject = [self captureRubyStdout];

    VALUE ary = rb_ary_new2(1);
    rb_ary_store(ary, 0, rb_str_new2([snippet UTF8String]));

    exception = nil;

    rb_rescue(evaluateString, ary, exceptionHandler, Qnil);

    // Let the caller know that we're done, including any exceptions that occurred and any captured output

    [engine snippetComplete:exception withOutput:[self prepareCapturedRubyStdout:stringIOObject]];
}

@end
