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

#import "NBPythonEngine.h"

@implementation NBPythonValue

- (NSString *)asString
{
    return @"asdfasdfasdfasdfasdf";
}

@end

@implementation NBPythonEngine

- (id)init
{
    self = [super init];
    
    if(self != nil)
    {
        Py_Initialize();
        
        globals = PyDict_New();
        locals = PyDict_New(); // TODO: global locals? seems wrong...
    }
    
    return self;
}


- (NBCompilationError *)executeSnippet:(NSString *)snippet
{
    PyObject * codeObject = Py_CompileString([snippet UTF8String], "snippet", Py_file_input);
    
    if(!codeObject)
    {
        NBCompilationError * err;
        
        err = [[NBCompilationError alloc] init];
        
        if(PyErr_Occurred())
        {
            PyObject * exceptionType, * exceptionValue, * exceptionTraceback;
            PyObject * exceptionOffset, * exceptionLine, * exceptionMessage;

            PyErr_Fetch(&exceptionType, &exceptionValue, &exceptionTraceback);
            PyErr_NormalizeException(&exceptionType, &exceptionValue, &exceptionTraceback);
            
            exceptionOffset = PyObject_GetAttrString(exceptionValue, "offset");
            exceptionLine = PyObject_GetAttrString(exceptionValue, "lineno");
            exceptionMessage = PyObject_GetAttrString(exceptionValue, "msg");
            
            err.column = PyInt_AsLong(exceptionOffset);
            err.line = PyInt_AsLong(exceptionLine);
            err.message = [NSString stringWithUTF8String:PyString_AsString(exceptionMessage)];
            
            PyErr_Clear();
        }
        
        return err;
    }
    
    PyEval_EvalCode((PyCodeObject *)codeObject, globals, locals);
    
    return nil;
}

@end
